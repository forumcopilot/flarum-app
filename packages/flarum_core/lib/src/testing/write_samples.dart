/// The texts the write fixtures were recorded with (tool/record_write_fixtures.dart). A fixture for
/// a write is told apart by its attributes, so a test sends exactly these.
abstract final class WriteSamples {
  static const title = 'Written from the app';
  static const content = 'A discussion started by the composer tests.';
  static const noTagsContent = 'A discussion without its tags.';
  static const reply = 'A reply from the composer tests.';
  static const throttledReply = 'A second reply, straight after the first.';
  static const edit = 'The reply, edited.';
  static const editByOther = "An edit by someone whose post it isn't.";
  static const questionTitle = 'A question from the app';
  static const question = 'How does the app choose a best answer?';
  static const answer = 'The one who asked chooses it.';
}
