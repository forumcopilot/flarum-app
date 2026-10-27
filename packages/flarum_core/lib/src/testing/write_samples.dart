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

  /// carol's direct message to bob (flarum/messages, 2.0), and his answer.
  static const message = 'A direct message from the app.';
  static const messageReply = 'Got it, thanks.';

  /// Moderation (Milestone 5): the question's new title, a reply deleted for good, and why bob is
  /// suspended for a moment.
  static const renamedTitle = 'A question from the app, renamed';
  static const replyToDelete = 'This reply will be deleted.';
  static const suspendReason = 'Suspended by the app tests.';

  /// fof/polls: carol's discussion with a poll, the one she gets wrong first (it closes in the
  /// past), and her multiple-choice one.
  static const pollTitle = 'A poll from the app';
  static const pollContent = 'Which do you read on?';
  static const pollQuestion = 'Phone or tablet?';
  static const pollOptions = ['Phone', 'Tablet', 'Both'];
  static const multiplePollTitle = 'A multiple-choice poll from the app';
  static const multiplePollQuestion = 'Which do you use?';
  static const multiplePollOptions = ['Android', 'iOS', 'Desktop'];

  /// fof/drafts: carol's reply draft (then changed), a new discussion's and a private one's.
  static const draftReply = 'A reply saved for later.';
  static const draftReplyEdited = 'A reply saved for later, and changed.';
  static const draftTitle = 'A discussion saved for later';
  static const draftContent = 'Not ready to post yet.';
  static const draftPrivateTitle = 'A private word saved for later';
  static const draftPrivateContent = 'For bob, when it is ready.';

  /// alice's nickname for the profile fixtures, and one past flarum/nicknames' default 150
  /// characters, which the forum refuses.
  static const nickname = 'Alice Liddell';
  static final nicknameTooLong = 'A' * 151;
  static const avatarName = 'avatar-test.png';

  static const uploadImageName = 'composer-test.png';
  static const uploadFileName = 'composer-test.txt';
  static const uploadFileText = 'Uploaded by the composer tests.\n';

  /// A one-pixel PNG, base64.
  static const uploadImageBase64 =
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1PeAAAADElEQVR4nGM4YWQEAALyAS2saifrAAAAAElFTkSuQmCC';
}
