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
  /// What a report says about the post (Milestone 4).
  static const flagDetail = 'Reported by the app tests.';

  /// The policy the recorder has the admin add for a while (fof/terms), and the reply it holds up.
  static const policyName = 'App test terms';
  static const policyUrl = 'https://example.com/terms';
  static const policyUpdate = 'Recorded by the app tests.';
  static const termsReply = 'Posted before accepting the terms.';

  /// carol's private discussion with bob (fof/byobu), and his reply.
  static const privateTitle = 'A private word from the app';
  static const privateContent = 'Only bob and I can read this.';
  static const privateReply = 'Read you, carol.';

  static const uploadImageName = 'composer-test.png';
  static const uploadFileName = 'composer-test.txt';
  static const uploadFileText = 'Uploaded by the composer tests.\n';

  /// A one-pixel PNG, base64.
  static const uploadImageBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGM4YWQEAALyAS2saifrAAAAAElFTkSuQmCC';
}
