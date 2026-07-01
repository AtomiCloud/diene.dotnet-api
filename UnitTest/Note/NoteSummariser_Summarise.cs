using System.Text;
using AtomiCloud.DotnetBase.Lib.Note;
using FluentAssertions;

namespace AtomiCloud.DotnetBase.UnitTest.Note;

public class NoteSummariser_Summarise
{
    [Fact]
    public void It_should_return_the_full_line_when_within_the_limit()
    {
        // Arrange
        var subject = new NoteSummariser();
        var input = new NoteRecord { Title = "Hello", Body = "world" };

        // Act
        var actual = subject.Summarise(input, 80);

        // Assert
        actual.Should().Be("Hello — world");
    }

    [Fact]
    public void It_should_collapse_internal_whitespace_into_single_spaces()
    {
        // Arrange
        var subject = new NoteSummariser();
        var input = new NoteRecord { Title = "  Spaced   out  ", Body = "many\n\tgaps" };

        // Act
        var actual = subject.Summarise(input, 80);

        // Assert
        actual.Should().Be("Spaced out — many gaps");
    }

    [Fact]
    public void It_should_truncate_on_a_word_boundary_with_an_ellipsis()
    {
        // Arrange
        var subject = new NoteSummariser();
        var input = new NoteRecord { Title = "Release", Body = "notes describe everything that changed" };

        // Act
        var actual = subject.Summarise(input, 20);

        // Assert
        actual.Should().Be("Release — notes…");
        actual.Length.Should().BeLessThanOrEqualTo(20);
    }

    [Theory]
    [ClassData(typeof(SeparatorBoundary_Data))]
    public void It_should_not_leave_a_dangling_separator_when_truncating_between_parts(
        int maxLength, string expected)
    {
        // Arrange
        var subject = new NoteSummariser();
        var input = new NoteRecord { Title = "hello world", Body = "foo" };

        // Act
        var actual = subject.Summarise(input, maxLength);

        // Assert
        actual.Should().Be(expected);
        actual.Length.Should().BeLessThanOrEqualTo(maxLength);
    }

    [Theory]
    [ClassData(typeof(EmDashAtBoundary_Data))]
    public void It_should_distinguish_the_separator_from_a_content_em_dash(
        string title, string body, int maxLength, string expected)
    {
        // Arrange
        var subject = new NoteSummariser();
        var input = new NoteRecord { Title = title, Body = body };

        // Act
        var actual = subject.Summarise(input, maxLength);

        // Assert
        actual.Should().Be(expected);
        actual.Length.Should().BeLessThanOrEqualTo(maxLength);
    }

    [Theory]
    [ClassData(typeof(SurrogateBoundary_Data))]
    public void It_should_never_split_a_surrogate_pair_when_truncating(
        string title, int maxLength, string expected)
    {
        // Arrange
        var subject = new NoteSummariser();
        var input = new NoteRecord { Title = title, Body = "" };

        // Act
        var actual = subject.Summarise(input, maxLength);

        // Assert
        actual.Should().Be(expected);
        actual.Length.Should().BeLessThanOrEqualTo(maxLength);
        // The preview must be structurally valid Unicode: no orphaned surrogate code units.
        actual.EnumerateRunes().Should().NotContain(rune => rune == Rune.ReplacementChar);
    }

    [Fact]
    public void It_should_never_exceed_max_length_when_no_word_boundary_fits()
    {
        // Arrange
        var subject = new NoteSummariser();
        var input = new NoteRecord { Title = "Antidisestablishmentarianism", Body = "" };

        // Act
        var actual = subject.Summarise(input, 5);

        // Assert
        actual.Should().Be("Anti…");
        actual.Length.Should().BeLessThanOrEqualTo(5);
    }

    [Fact]
    public void It_should_omit_the_separator_when_the_body_is_empty()
    {
        // Arrange
        var subject = new NoteSummariser();
        var input = new NoteRecord { Title = "Only title", Body = "" };

        // Act
        var actual = subject.Summarise(input, 80);

        // Assert
        actual.Should().Be("Only title");
    }

    [Fact]
    public void It_should_omit_the_separator_when_the_title_is_empty()
    {
        // Arrange
        var subject = new NoteSummariser();
        var input = new NoteRecord { Title = "   ", Body = "Body only" };

        // Act
        var actual = subject.Summarise(input, 80);

        // Assert
        actual.Should().Be("Body only");
    }

    [Fact]
    public void It_should_return_an_empty_string_when_both_parts_are_blank()
    {
        // Arrange
        var subject = new NoteSummariser();
        var input = new NoteRecord { Title = "", Body = "  \t " };

        // Act
        var actual = subject.Summarise(input, 80);

        // Assert
        actual.Should().BeEmpty();
    }

    [Theory]
    [ClassData(typeof(InvalidMaxLength_Data))]
    public void It_should_reject_a_non_positive_max_length(int maxLength)
    {
        // Arrange
        var subject = new NoteSummariser();
        var input = new NoteRecord { Title = "Any", Body = "thing" };

        // Act
        var act = () => subject.Summarise(input, maxLength);

        // Assert
        act.Should().Throw<ArgumentOutOfRangeException>();
    }

    private sealed class SeparatorBoundary_Data : TheoryData<int, string>
    {
        public SeparatorBoundary_Data()
        {
            // "hello world — foo" (length 17); clip windows that end on the " — "
            // separator must not leave a dangling em dash before the ellipsis.
            Add(14, "hello world…");
            Add(15, "hello world…");
            Add(16, "hello world…");
            Add(17, "hello world — foo");
        }
    }

    private sealed class EmDashAtBoundary_Data : TheoryData<string, string, int, string>
    {
        public EmDashAtBoundary_Data()
        {
            // H1: the body's own leading em dash abuts the join separator, so the
            // collapsed text holds two adjacent em dashes (" — — "). When the clip
            // keeps only that orphaned body em dash, drop the body and its separator
            // rather than leave a dangling "Title —…".
            Add("hello", "— foo", 11, "hello…");
            Add("Quote", "— Twain", 12, "Quote…");

            // H2: a content em dash inside a single field (no body, so no separator)
            // is real text and must be preserved, not mistaken for the separator.
            Add("hello — foo", "", 9, "hello —…");

            // Guard: when real body words survive past the separator, the separator is
            // legitimate content and stays — over-stripping must not eat it.
            Add("Title", "real body text", 14, "Title — real…");
        }
    }

    private sealed class SurrogateBoundary_Data : TheoryData<string, int, string>
    {
        public SurrogateBoundary_Data()
        {
            // "😀" is one astral-plane character encoded as two UTF-16 code units. A clip that
            // lands between its halves must not emit the orphaned high surrogate.
            // Budget splits the pair with no safe slice point -> drop it entirely.
            Add("😀boom", 2, "…");
            // A preceding ASCII char gives a safe boundary -> keep "a", drop the split emoji.
            Add("a😀boom", 3, "a…");
            // The whole pair fits before the clip point -> the emoji is preserved intact.
            Add("😀 boom", 4, "😀…");
        }
    }

    private sealed class InvalidMaxLength_Data : TheoryData<int>
    {
        public InvalidMaxLength_Data()
        {
            Add(0);
            Add(-1);
            Add(-100);
        }
    }
}
