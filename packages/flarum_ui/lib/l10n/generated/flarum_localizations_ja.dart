// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'flarum_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class FlarumLocalizationsJa extends FlarumLocalizations {
  FlarumLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get attachmentDefaultName => '添付ファイル';

  @override
  String get share => '共有';

  @override
  String get cancel => 'キャンセル';

  @override
  String downloading(String filename) {
    return '$filenameをダウンロード中...';
  }

  @override
  String get download => 'ダウンロード';

  @override
  String errorDownloading(String filename, String error) {
    return '$filenameのダウンロードエラー: $error';
  }

  @override
  String get video => '動画';

  @override
  String get viewOnWeb => 'Webで表示';

  @override
  String get mediaPause => '一時停止';

  @override
  String get mediaPlay => '再生';

  @override
  String get failedToLoadVideo => '動画を読み込めませんでした';

  @override
  String get close => '閉じる';

  @override
  String get spoiler => 'ネタバレ';

  @override
  String get image => '画像';

  @override
  String get fileTypeArchive => '圧縮ファイル';

  @override
  String get fileTypeAudio => '音声';

  @override
  String get fileTypeFile => 'ファイル';

  @override
  String get fileTypeText => 'テキスト';

  @override
  String get retry => '再試行';

  @override
  String get edited => '編集済み';

  @override
  String nReplies(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 件の返信',
    );
    return '$_temp0';
  }

  @override
  String summaryLikeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'いいね $count 件',
    );
    return '$_temp0';
  }

  @override
  String get loadMore => 'さらに読み込む';

  @override
  String viewProfileOfUser(String username) {
    return '$username さんのプロフィールを見る';
  }

  @override
  String get loadEarlierPosts => '以前の投稿を読み込む';

  @override
  String get postHidden => 'この投稿は削除されました。';

  @override
  String get threadLoadFailed => 'このディスカッションを読み込めませんでした。';

  @override
  String eventRenamed(String user, String from, String to) {
    return '$userがタイトルを「$from」から「$to」に変更しました。';
  }

  @override
  String eventLocked(String user) {
    return '$userがディスカッションをロックしました。';
  }

  @override
  String eventUnlocked(String user) {
    return '$userがディスカッションのロックを解除しました。';
  }

  @override
  String eventStickied(String user) {
    return '$userがディスカッションを固定しました。';
  }

  @override
  String eventUnstickied(String user) {
    return '$userがディスカッションの固定を解除しました。';
  }

  @override
  String eventTagged(String user) {
    return '$userがタグを変更しました。';
  }

  @override
  String eventOther(String user) {
    return '$userがディスカッションを変更しました。';
  }

  @override
  String get someone => '誰か';

  @override
  String get latest => '最新';

  @override
  String get unread => '未読';

  @override
  String get search => '検索';

  @override
  String get signIn => 'ログイン';

  @override
  String get profile => 'プロフィール';

  @override
  String get following => 'フォロー中';

  @override
  String get home => 'ホーム';

  @override
  String get notifications => '通知';

  @override
  String get settings => '設定';

  @override
  String get tags => 'タグ';

  @override
  String get filterTop => 'トップ';

  @override
  String get viewNewest => '新規';

  @override
  String discussionReplied(String user, String time) {
    return '$userが$timeに返信';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$userが$timeに開始';
  }

  @override
  String get noDiscussions => 'まだディスカッションはありません。';

  @override
  String get discussionsLoadFailed => 'ディスカッションを読み込めませんでした。';

  @override
  String get tagsLoadFailed => 'タグを読み込めませんでした。';

  @override
  String get signOut => 'サインアウト';

  @override
  String get account => 'アカウント';

  @override
  String get createAccount => 'アカウントを作成';

  @override
  String signInFailedReason(String reason) {
    return 'ログインできませんでした：$reason';
  }

  @override
  String get signInHint => 'フォーラムのページでログインしてください。ログアウトするまでログイン状態が保たれます。';

  @override
  String signedInAs(String name) {
    return '$nameとしてログイン中';
  }

  @override
  String get allNotificationsMarkedAsRead => 'すべての通知を既読にしました';

  @override
  String get failedToMarkNotificationsRead => '通知を既読にできませんでした';

  @override
  String get noNotificationsYet => 'まだ通知はありません';

  @override
  String notifNewPost(String user, String title) {
    return '$userが$titleに返信しました';
  }

  @override
  String notifPostLiked(String user, String title) {
    return '$userが$titleのあなたの投稿にいいねしました';
  }

  @override
  String notifPostReacted(String user, String title) {
    return '$userが$titleのあなたの投稿にリアクションしました';
  }

  @override
  String notifPostMentioned(String user, String title) {
    return '$userが$titleのあなたの投稿に返信しました';
  }

  @override
  String notifUserMentioned(String user, String title) {
    return '$userが$titleであなたをメンションしました';
  }

  @override
  String notifGroupMentioned(String user, String title) {
    return '$userが$titleであなたの所属グループをメンションしました';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$userがディスカッションの名前を$titleに変更しました';
  }

  @override
  String notifLocked(String user, String title) {
    return '$userが$titleをロックしました';
  }

  @override
  String notifNewDiscussion(String user, String title) {
    return '$userが$titleを開始しました';
  }

  @override
  String notifMovedToTag(String user, String title) {
    return '$userが$titleをあなたがフォロー中のタグに移動しました';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$userがあなたとの非公開ディスカッションを開始しました：$title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$userが非公開ディスカッション$titleに返信しました';
  }

  @override
  String notifPrivateAdded(String user, String title) {
    return '$userがあなたを非公開ディスカッション$titleに追加しました';
  }

  @override
  String notifPrivateRemoved(String user, String title) {
    return '$userがあなたを非公開ディスカッション$titleから外しました';
  }

  @override
  String notifMadePublic(String user, String title) {
    return '$userが$titleを公開しました';
  }

  @override
  String notifBestAnswerAwarded(String user, String title) {
    return '$userが$titleであなたの投稿をベストアンサーに選びました';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$userが$titleでベストアンサーを選びました';
  }

  @override
  String notifBestAnswerPending(String title) {
    return '$titleでベストアンサーを選んでください';
  }

  @override
  String notifMessage(String user) {
    return '$userからメッセージが届きました';
  }

  @override
  String get notifSuspended => 'アカウントが一時停止されました';

  @override
  String get notifUnsuspended => 'アカウントの一時停止が解除されました';

  @override
  String get notifExport => 'データのエクスポートの準備ができました';

  @override
  String get notifOther => '新しい通知';

  @override
  String get aDiscussion => 'ディスカッション';

  @override
  String get notificationsLoadFailed => '通知を読み込めませんでした。';

  @override
  String get notificationsSignIn => '通知を見るにはログインしてください。';

  @override
  String get markAllRead => 'すべて既読にする';

  @override
  String get posts => '投稿';

  @override
  String profileJoined(String date) {
    return '$date に参加';
  }

  @override
  String get discussionsTab => 'ディスカッション';

  @override
  String lastSeen(String time) {
    return '最終ログイン：$time';
  }

  @override
  String userStats(int discussions, int comments) {
    String _temp0 = intl.Intl.pluralLogic(
      discussions,
      locale: localeName,
      other: 'ディスカッション$discussions件',
    );
    String _temp1 = intl.Intl.pluralLogic(
      comments,
      locale: localeName,
      other: '投稿$comments件',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get userLoadFailed => 'このプロフィールを読み込めませんでした。';

  @override
  String get noPostsYet => 'まだ投稿はありません。';

  @override
  String searchFailedWithError(String error) {
    return '検索に失敗しました: $error';
  }

  @override
  String get searchHint => 'ディスカッションと投稿を検索';

  @override
  String noResultsFor(String query) {
    return '「$query」に一致する結果はありません。';
  }

  @override
  String get light => 'ライト';

  @override
  String get dark => 'ダーク';

  @override
  String get appearance => '外観';

  @override
  String get appearanceSystem => '端末の設定';

  @override
  String repliedByOne(String a) {
    return '$aが返信しました。';
  }

  @override
  String repliedByTwo(String a, String b) {
    return '$aと$bが返信しました。';
  }

  @override
  String repliedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others件',
    );
    return '$a、$bほか$_temp0の返信があります。';
  }

  @override
  String get repliesTitle => '返信';

  @override
  String postNumber(int number) {
    return '投稿 #$number';
  }

  @override
  String repliedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others件',
    );
    return '$aほか$_temp0の返信があります。';
  }

  @override
  String eventTagsAdded(String user, String tags) {
    return '$userが$tagsを追加しました。';
  }

  @override
  String eventTagsRemoved(String user, String tags) {
    return '$userが$tagsを削除しました。';
  }

  @override
  String eventTagsMoved(String user, String added, String removed) {
    return '$userが$addedを追加し、$removedを削除しました。';
  }

  @override
  String get privateDiscussion => '非公開ディスカッション';

  @override
  String get bestAnswer => 'ベストアンサー';

  @override
  String get goToBestAnswer => 'ベストアンサーへ移動';

  @override
  String get answered => '解決済み';

  @override
  String eventRecipientsChanged(String user) {
    return '$userがこの非公開ディスカッションの参加者を変更しました。';
  }

  @override
  String get noTagsOnForum => 'このフォーラムはタグを使用していません。';

  @override
  String get permissionRequired => '権限が必要です';

  @override
  String get bold => '太字';

  @override
  String get underline => '下線';

  @override
  String get strikethrough => '取り消し線';

  @override
  String get bulletList => '箇条書きリスト';

  @override
  String get numberedList => '番号付きリスト';

  @override
  String get listItem => 'リスト項目';

  @override
  String get mentionUser => 'ユーザーをメンション';

  @override
  String get title => 'タイトル';

  @override
  String get content => 'コンテンツ';

  @override
  String get send => '送信';

  @override
  String get save => '保存';

  @override
  String get formatting => '書式設定';

  @override
  String get pleaseEnterTitle => 'タイトルを入力してください';

  @override
  String get pleaseEnterContent => 'コンテンツを入力してください';

  @override
  String get composerTitleHint => 'タイトルを書く...';

  @override
  String get composerContentHint => '内容を書く...';

  @override
  String get composerFormattingHint => '書式オプションを開く';

  @override
  String get searchUsers => 'ユーザーを検索...';

  @override
  String get startDiscussion => 'ディスカッションを開始';

  @override
  String get editPost => '投稿を編集';

  @override
  String get postingThrottled => '投稿の間隔が短すぎます。数秒待ってからもう一度お試しください。';

  @override
  String get postAwaitingApproval => '送信しました。モデレーターが承認すると表示されます。';

  @override
  String get chooseTags => 'タグを選択';

  @override
  String get primaryTags => 'メインタグ';

  @override
  String get secondaryTags => 'その他のタグ';

  @override
  String tagsNeedPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'メインタグを$countつ選んでください。',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManyPrimary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'メインタグは$countつまでです。',
    );
    return '$_temp0';
  }

  @override
  String tagsNeedSecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'あと$countつタグを選んでください。',
    );
    return '$_temp0';
  }

  @override
  String tagsTooManySecondary(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'その他のタグは$countつまでです。',
    );
    return '$_temp0';
  }

  @override
  String get done => '完了';

  @override
  String get noMembersFound => 'メンバーが見つかりません。';

  @override
  String get memberSearchNotAllowed => 'このフォーラムではメンバーを検索できません。';

  @override
  String get editLoadFailed => '編集のためにこの投稿を読み込めませんでした。';

  @override
  String get like => 'いいね';

  @override
  String get unlike => 'いいねを取り消す';

  @override
  String get react => 'リアクション';

  @override
  String get reactions => 'リアクション';

  @override
  String get bookmark => 'ブックマーク';

  @override
  String get removeBookmark => 'ブックマークを外す';

  @override
  String get bookmarks => 'ブックマーク';

  @override
  String get noBookmarks => 'まだブックマークはありません。';

  @override
  String get chooseBestAnswer => 'ベストアンサーに選ぶ';

  @override
  String get removeBestAnswer => 'ベストアンサーを取り消す';

  @override
  String get notificationSettings => 'このディスカッションの通知';

  @override
  String get notFollowing => 'フォローしていない';

  @override
  String get notFollowingHint => '@メンションされたときだけ通知します。';

  @override
  String get followingHint => 'すべての返信を通知します。';

  @override
  String get ignoring => '無視';

  @override
  String get ignoringHint => '通知せず、一覧からも非表示にします。';

  @override
  String get tagFollowingHint => '新しいディスカッションを通知します。';

  @override
  String get lurking => '見守り';

  @override
  String get lurkingHint => '新しいディスカッションとすべての返信を通知します。';

  @override
  String get tagIgnoringHint => 'ここのディスカッションは通知しません。';

  @override
  String get hidden => '非表示';

  @override
  String get hiddenHint => 'このタグのディスカッションを一覧から非表示にします。';

  @override
  String get attachFile => 'ファイルを添付';

  @override
  String get uploadImage => '画像をアップロード';

  @override
  String get takePhoto => '写真を撮る';

  @override
  String uploadingFilename(String filename) {
    return 'アップロード中: $filename…';
  }

  @override
  String failedToUploadFile2(Object errorMessage) {
    return 'ファイルをアップロードできませんでした: $errorMessage';
  }

  @override
  String get pleaseWaitForAttachmentsToFinishUploading =>
      '添付ファイルのアップロード完了までお待ちください';

  @override
  String imageResizedToFitLimit(
      String fileName, String size, String dimensions, String limit) {
    return '$fileName を上限 $limit に収まるよう $size$dimensions に縮小しました。';
  }

  @override
  String imageTooLargeCouldNotResize(
      String fileName, String size, String limit) {
    return '$fileName: サイズが大きすぎ（$size）、縮小できませんでした。上限は $limit です。';
  }

  @override
  String fileTooLargeForForum(
      Object fileName, Object fileBytes, Object maxBytes) {
    return '$fileName は $fileBytes です。このフォーラムの上限は $maxBytes です。';
  }

  @override
  String get flagAction => '通報';

  @override
  String get ignoredUsers => '無視中のユーザー';

  @override
  String get ignoredUsersEmpty => '無視しているユーザーはいません。';

  @override
  String get flagPostTitle => '投稿を通報';

  @override
  String get flagReasonOffTopic => '話題から外れている';

  @override
  String get flagReasonOffTopicText => 'この投稿は現在のディスカッションに関係がなく、別の場所に移すべきです。';

  @override
  String get flagReasonInappropriate => '不適切';

  @override
  String get flagReasonInappropriateText =>
      'この投稿は攻撃的・侮辱的であるか、コミュニティのガイドラインに違反しています。';

  @override
  String get flagReasonSpam => 'スパム';

  @override
  String get flagReasonSpamText => 'この投稿は広告です。';

  @override
  String get flagReasonOther => 'その他（具体的に記入）';

  @override
  String get flagDetails => '詳細（任意）';

  @override
  String get flagDetailsNeeded => 'モデレーターのために詳細を入力してください。';

  @override
  String get communityGuidelines => 'コミュニティガイドライン';

  @override
  String get flagSent => '通報ありがとうございます。モデレーターが確認します。';

  @override
  String ignoreUser(String name) {
    return '$nameを無視';
  }

  @override
  String stopIgnoringUser(String name) {
    return '$nameの無視をやめる';
  }

  @override
  String ignoreUserConfirm(String name) {
    return '$nameを無視しますか？この人の投稿は折りたたまれます。アカウントからいつでも解除できます。';
  }

  @override
  String ignoredUserPost(String name) {
    return '無視している$nameの投稿です。';
  }

  @override
  String get showPost => '投稿を表示';

  @override
  String get ignoredOnThisPhone => 'このフォーラムには無視リストがないため、アプリがこの端末に保存します。';

  @override
  String get stopIgnoring => '無視をやめる';

  @override
  String get termsBanner => '投稿を再開するには、このフォーラムの更新された規約に同意してください。';

  @override
  String get termsReview => '確認';

  @override
  String get termsTitle => '規約の更新';

  @override
  String get termsIntro => '再び投稿する前に、フォーラムの更新されたポリシーに同意してください。';

  @override
  String get readPolicy => '読む';

  @override
  String get acceptTerms => '同意する';

  @override
  String get termsAccepted => 'ありがとうございます。再び投稿できます。';
}
