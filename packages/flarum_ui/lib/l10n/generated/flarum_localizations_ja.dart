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
  String get copyLink => 'リンクをコピー';

  @override
  String get linkCopied => 'リンクをコピーしました。';

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
  String get saveImage => '画像を保存';

  @override
  String get imageSaved => '画像を保存しました。';

  @override
  String get imageSaveFailed => '画像を保存できませんでした。';

  @override
  String get imageSaveNotAllowed => 'このアプリには写真への保存が許可されていません。端末の設定で許可できます。';

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
  String get loadEarlierPosts => 'さらに読み込む';

  @override
  String scrubberPosition(int index, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$index / $count 件',
      one: '$index / $count 件',
    );
    return '$_temp0';
  }

  @override
  String get scrubberOriginalPost => '最初の投稿';

  @override
  String get scrubberNow => '最新の投稿';

  @override
  String timeGapDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count日後',
    );
    return '$_temp0';
  }

  @override
  String timeGapMonths(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countか月後',
    );
    return '$_temp0';
  }

  @override
  String timeGapYears(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count年後',
    );
    return '$_temp0';
  }

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
  String get someone => '[削除済み]';

  @override
  String get latest => '最新';

  @override
  String get unread => '未読';

  @override
  String get search => '検索';

  @override
  String get signIn => 'ログイン';

  @override
  String get logInToReply => 'ログインして返信';

  @override
  String get cannotReply => '返信不可';

  @override
  String get profile => 'プロフィール';

  @override
  String get following => 'フォロー中';

  @override
  String get follow => 'フォロー';

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
  String get allDiscussions => 'すべてのスレッド';

  @override
  String get sortOldest => '古い順';

  @override
  String get sortTitleAz => 'タイトル (A–Z)';

  @override
  String get sortTitleZa => 'タイトル (Z–A)';

  @override
  String get changeSorting => 'スレッド一覧の並び順を変更する';

  @override
  String get toggleNavigation => 'ナビゲーションドロップダウンメニューの切り替え';

  @override
  String discussionReplied(String user, String time) {
    return '$userが$timeに返信';
  }

  @override
  String discussionStarted(String user, String time) {
    return '$userが$timeに開始';
  }

  @override
  String get noDiscussions => '一致するディスカッションが見つかりません。';

  @override
  String get discussionsLoadFailed => 'ディスカッションを読み込めませんでした。';

  @override
  String get tagsLoadFailed => 'タグを読み込めませんでした。';

  @override
  String get signOut => 'ログアウト';

  @override
  String logOutQuestion(String forum) {
    return '$forumからログアウトしますか？';
  }

  @override
  String get account => 'アカウント';

  @override
  String get createAccount => '新規登録';

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
  String get noNotificationsYet => '通知なし';

  @override
  String notifNewPost(String user, String title) {
    return '$userが$titleに投稿しました';
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
    return '$userが$titleであなたの所属するグループをメンションしました';
  }

  @override
  String notifRenamed(String user, String title) {
    return '$userがタイトルを$titleに変更しました';
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
    return '$userが$titleのタグを変更しました';
  }

  @override
  String notifPrivateCreated(String user, String title) {
    return '$userがあなたとの非公開ディスカッションを開始しました：$title';
  }

  @override
  String notifPrivateReplied(String user, String title) {
    return '$userがあなたの参加している非公開ディスカッションに投稿しました：$title';
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
    return '$titleであなたの投稿が$userによってベストアンサーに選ばれました';
  }

  @override
  String notifBestAnswerChosen(String user, String title) {
    return '$userが$titleのベストアンサーを選びました';
  }

  @override
  String notifBestAnswerPending(String title) {
    return 'あなたの質問が解決された場合は、$titleでベストアンサーを選んでください';
  }

  @override
  String notifMessage(String user) {
    return '$userからメッセージが届きました';
  }

  @override
  String get notifSuspended => 'アカウントが一時停止されました';

  @override
  String get notifUnsuspended => 'アカウント利用停止が解除されました';

  @override
  String get notifExport => 'データのエクスポートの準備ができました';

  @override
  String get notifOther => '新しい通知';

  @override
  String notifLineNewPost(String user) {
    return '$user が投稿しました';
  }

  @override
  String notifLinePostLiked(String user) {
    return '$user が「いいね」しました';
  }

  @override
  String notifLinePostReacted(String user) {
    return '$userがあなたの投稿にリアクションしました';
  }

  @override
  String notifLinePostMentioned(String user) {
    return '$user があなたの投稿に返信しました';
  }

  @override
  String notifLineUserMentioned(String user) {
    return '$user があなたをメンションしました';
  }

  @override
  String notifLineGroupMentioned(String user) {
    return '$userがあなたの所属するグループをメンションしました';
  }

  @override
  String notifLineRenamed(String user) {
    return '$user がタイトルを変更しました';
  }

  @override
  String notifLineLocked(String user) {
    return '$user がロックしました';
  }

  @override
  String notifLineNewDiscussion(String user) {
    return '$userがディスカッションを開始しました';
  }

  @override
  String notifLineMovedToTag(String user) {
    return '$userさんがタグを変更しました';
  }

  @override
  String notifLinePrivateCreated(String user) {
    return '$userがあなたとの非公開ディスカッションを開始しました';
  }

  @override
  String notifLinePrivateReplied(String user) {
    return '$userがあなたの参加している非公開ディスカッションに投稿しました';
  }

  @override
  String notifLinePrivateAdded(String user) {
    return '$userがあなたを非公開ディスカッションに追加しました';
  }

  @override
  String notifLinePrivateRemoved(String user) {
    return '$userがあなたを非公開ディスカッションから外しました';
  }

  @override
  String notifLineMadePublic(String user) {
    return '$userが参加者をすべて外し、ディスカッションを公開しました';
  }

  @override
  String notifLineBestAnswerAwarded(String user) {
    return 'あなたの投稿が$userによってベストアンサーに選ばれました';
  }

  @override
  String notifLineBestAnswerChosen(String user) {
    return '$userがこのディスカッションのベストアンサーを選びました';
  }

  @override
  String get notifLineBestAnswerPending => 'あなたの質問が解決された場合は、ベストアンサーを選んでください。';

  @override
  String get aDiscussion => 'ディスカッション';

  @override
  String get notificationsLoadFailed => '通知を読み込めませんでした。';

  @override
  String get notificationsSignIn => '通知を見るにはログインしてください。';

  @override
  String get markAllRead => 'すべて既読にする';

  @override
  String get markAsRead => '既読にする';

  @override
  String get markAllDiscussionsReadQuestion => 'すべてのディスカッションを既読にしますか？';

  @override
  String get hideWelcomeMessage => 'ウェルカムメッセージを隠す';

  @override
  String get posts => '投稿';

  @override
  String get usersTab => 'ユーザー';

  @override
  String get likesTab => 'いいね';

  @override
  String get mentionsTab => 'メンション';

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
  String get online => 'オンライン';

  @override
  String bestAnswerCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件',
    );
    return 'ベストアンサー$_temp0';
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
  String get noPostsYet => '投稿はありません。';

  @override
  String searchFailedWithError(String error) {
    return '検索に失敗しました: $error';
  }

  @override
  String get searchHint => 'フォーラムを検索';

  @override
  String get recentSearches => '最近の検索';

  @override
  String get clearRecentSearches => 'クリア';

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
  String get repliesTitle => 'この投稿への返信';

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
  String get mentionUser => 'ユーザー、投稿、グループをメンション';

  @override
  String get title => 'タイトル';

  @override
  String get content => 'コンテンツ';

  @override
  String get send => 'メッセージを送信';

  @override
  String get postReply => '返信する';

  @override
  String get postDiscussion => 'ディスカッションを作成';

  @override
  String get postPrivateDiscussion => '非公開ディスカッションを投稿';

  @override
  String get save => '変更を保存';

  @override
  String get discardReplyQuestion => 'まだ返信が完了していません。内容を破棄してもよろしいですか？';

  @override
  String get discardDiscussionQuestion => 'まだ投稿が完了していません。内容を破棄してもよろしいですか？';

  @override
  String get discardEditQuestion => 'まだ変更を保存していません。内容を破棄してもよろしいですか？';

  @override
  String get discard => '破棄';

  @override
  String get saveDraft => '下書きを保存';

  @override
  String get formatting => '書式設定';

  @override
  String get addBold => '太字を追加';

  @override
  String get addItalic => '斜体を追加';

  @override
  String get insertQuote => '引用を追加';

  @override
  String get addLink => 'リンクを追加';

  @override
  String get addBulletedList => '箇条書きを追加';

  @override
  String get insertCode => 'コードを追加';

  @override
  String get pleaseEnterTitle => 'タイトルを入力してください';

  @override
  String get pleaseEnterContent => 'コンテンツを入力してください';

  @override
  String get composerTitleHint => 'ディスカッションのタイトル';

  @override
  String get privateDiscussionTitleHint => '非公開ディスカッションのタイトル';

  @override
  String get composerContentHint => '本文を入力...';

  @override
  String get composerReplyHint => '返信を入力...';

  @override
  String get composerFormattingHint => '書式オプションを開く';

  @override
  String get searchUsers => 'ユーザーを検索...';

  @override
  String get startDiscussion => 'ディスカッションの作成';

  @override
  String get editPost => '投稿を編集';

  @override
  String get postingThrottled => '操作が早すぎます。数秒後に再度お試しください。';

  @override
  String get postAwaitingApproval => '送信しました。モデレーターが承認すると表示されます。';

  @override
  String get chooseTags => 'タグを選択';

  @override
  String get ok => 'OK';

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
  String likedByOne(String a) {
    return '$aが「いいね」しました。';
  }

  @override
  String likedByTwo(String a, String b) {
    return '$aと$bが「いいね」しました。';
  }

  @override
  String likedByOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others人',
    );
    return '$aほか$_temp0が「いいね」しました。';
  }

  @override
  String likedByMore(String a, String b, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others人',
    );
    return '$a、$bほか$_temp0が「いいね」しました。';
  }

  @override
  String get likedByYou => 'あなたが「いいね」しました。';

  @override
  String likedByYouAndOne(String a) {
    return 'あなたと$aが「いいね」しました。';
  }

  @override
  String likedByYouOneMore(String a, int others) {
    String _temp0 = intl.Intl.pluralLogic(
      others,
      locale: localeName,
      other: '$others人',
    );
    return 'あなた、$aほか$_temp0が「いいね」しました。';
  }

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
  String get removeBestAnswer => 'ベストアンサーを解除する';

  @override
  String get notFollowing => 'フォローしない';

  @override
  String get notFollowingHint => '@メンションされたときだけ通知します。';

  @override
  String get followingHint => 'すべての返信を通知します。';

  @override
  String get ignoring => '無視';

  @override
  String get ignoringHint => '通知を停止し、ディスカッション一覧に表示しません。';

  @override
  String get tagFollowingHint => '新しいディスカッションの作成を通知します。';

  @override
  String get lurking => '見守り';

  @override
  String get lurkingHint => 'すべての新規ディスカッションと返信を通知します。';

  @override
  String get tagIgnoringHint => '通知を停止します。';

  @override
  String get hidden => '非表示中';

  @override
  String get hiddenHint => 'ディスカッション一覧に表示しません。';

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
    return '$fileName は $fileBytes です。$maxBytes を超えるアップロードはできません。';
  }

  @override
  String get flagAction => '通報';

  @override
  String get ignoredUsers => '無視されたユーザー';

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
      'この投稿は悪意のある表現や暴力的表現、あるいはコミュニティガイドラインに違反した内容を含んでいます。';

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
  String get flaggedPosts => '報告された投稿';

  @override
  String get noFlags => '報告された投稿はありません';

  @override
  String flaggedPostItem(String username, String discussion) {
    return '$discussionにおける$username';
  }

  @override
  String flaggedByWithReason(String username, String reason) {
    return '$username が $reason であると報告しました';
  }

  @override
  String flaggedBy(String username) {
    return '$username が報告しました';
  }

  @override
  String get dismissFlag => '報告を却下する';

  @override
  String ignoreUser(String name) {
    return '$nameを無視';
  }

  @override
  String stopIgnoringUser(String name) {
    return '$nameの無視を解除';
  }

  @override
  String ignoreUserConfirm(String name) {
    return '$nameを無視しますか？';
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
  String get stopIgnoring => '無視を解除';

  @override
  String get termsBanner => '新しい利用規約を確認している間、アカウントへのアクセスを一時的に制限しました。';

  @override
  String get termsReview => '確認';

  @override
  String get termsTitle => '利用規約の更新';

  @override
  String get termsIntro => '前回のアクセス以降、利用規約が更新されました';

  @override
  String get readPolicy => '読む';

  @override
  String get acceptTerms => '確認';

  @override
  String get termsAccepted => '承諾いただきありがとうございます、フォーラムへ戻ることができます';

  @override
  String get privateDiscussions => '非公開ディスカッション';

  @override
  String get startPrivateDiscussion => '非公開ディスカッションの作成';

  @override
  String privateWith(String names) {
    return '$namesと';
  }

  @override
  String get addPerson => '参加者';

  @override
  String get choosePerson =>
      'このディスカッションはあなたがここで選択したユーザーにのみ表示されます。あなた以外の参加者が少なくとも1人必要です。';

  @override
  String get noPrivateDiscussions => '一致するディスカッションが見つかりません。';

  @override
  String get privateOnlyOne => 'このフォーラムでは、一度に1人にだけ非公開で書けます。';

  @override
  String get messages => 'メッセージ';

  @override
  String get markAllMessagesRead => 'すべて既読にする';

  @override
  String get startOfConversation => '会話の始まり';

  @override
  String get messageCopied => 'メッセージをコピーしました。';

  @override
  String get newMessage => '新しいメッセージ';

  @override
  String get noMessages => 'メッセージはまだありません。';

  @override
  String get sendMessage => 'メッセージを送る';

  @override
  String get messageHint => 'メッセージを入力…';

  @override
  String get messagesLoadFailed => 'メッセージを読み込めませんでした。';

  @override
  String get moderate => 'モデレート';

  @override
  String get renameDiscussion => '名前を変更';

  @override
  String get editTags => 'タグの編集';

  @override
  String get renameDiscussionTitle => 'タイトルの変更';

  @override
  String get lockDiscussion => 'ロック';

  @override
  String get unlockDiscussion => 'ロック解除';

  @override
  String get stickDiscussion => '固定';

  @override
  String get unstickDiscussion => '固定を解除';

  @override
  String get restore => '復元';

  @override
  String get deleteForever => '完全に削除';

  @override
  String get deleteForeverConfirm => '完全に削除しますか？この操作は取り消すことができません。';

  @override
  String get approve => '承認';

  @override
  String get unsuspend => '停止を解除';

  @override
  String get suspend => 'アカウント停止';

  @override
  String suspendUserTitle(String username) {
    return 'アカウント $username の停止';
  }

  @override
  String get suspensionStatus => 'アカウント状態';

  @override
  String get notSuspended => '停止解除';

  @override
  String get suspendIndefinitely => '無期限停止';

  @override
  String get suspendLimitedTime => '一時利用停止...';

  @override
  String get suspendDays => '日間';

  @override
  String get suspendReasonLabel => 'アカウント停止理由';

  @override
  String get suspendMessageLabel => 'ユーザーにメッセージを表示';

  @override
  String get optional => '任意';

  @override
  String suspendedUntil(String date) {
    return '$dateまで停止中';
  }

  @override
  String get suspendedIndefinitely => '無期限で停止中';

  @override
  String youAreSuspended(String date) {
    return 'この一時利用停止は$dateまで続きます';
  }

  @override
  String get youAreSuspendedIndefinitely => 'このアカウントは利用停止されています';

  @override
  String get awaitingApproval => '承認待ち';

  @override
  String get badgeSticky => 'ピン留め';

  @override
  String get badgeLocked => 'ロック中';

  @override
  String get badgeHidden => '非表示';

  @override
  String eventMerged(String user, int count, String titles) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の投稿',
    );
    return '$userが$titlesから$_temp0をこのディスカッションに統合しました。';
  }

  @override
  String eventSplitTo(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の投稿',
    );
    return '$userが$_temp0を$titleに分割しました。';
  }

  @override
  String eventSplitFrom(String user, int count, String title) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count件の投稿',
    );
    return '$userが$titleから$_temp0を分割しました。';
  }

  @override
  String get errorNoConnection => 'フォーラムに接続できませんでした。接続を確認して、もう一度お試しください。';

  @override
  String get errorTimedOut => 'フォーラムの応答に時間がかかりすぎています。もう一度お試しください。';

  @override
  String get errorBlocked =>
      'フォーラムのファイアウォールによってアプリがブロックされました。しばらくしてから再度お試しいただくか、ブラウザでフォーラムを開いてください。';

  @override
  String get errorNotFound => '要求されたリソースが見つかりませんでした。';

  @override
  String get errorRateLimited => '操作が早すぎます。数秒後に再度お試しください。';

  @override
  String get errorForumDown => 'フォーラムが現在応答していません。しばらくしてからもう一度お試しください。';

  @override
  String get errorNotAllowed => 'この操作を実行する権限がありません。';

  @override
  String get errorUnknown => 'エラーが発生しました。再度お試しください。';

  @override
  String pollVotes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count票',
    );
    return '$_temp0';
  }

  @override
  String pollChooseUpTo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countつまで選べます',
    );
    return '$_temp0';
  }

  @override
  String get pollEnded => 'すでに締め切られた投票です';

  @override
  String pollEndsOn(String date) {
    return '投票の締め切り：$date';
  }

  @override
  String get pollResultsAfterVoting => '投票すると結果が表示されます。';

  @override
  String get pollResultsWhenClosed => '投票終了後に結果が表示されます。';

  @override
  String get pollVote => '投票する';

  @override
  String get pollRemoveVote => '投票を取り消す';

  @override
  String get pollSeeVoters => '投票したユーザー一覧';

  @override
  String get pollNoVotes => 'まだ投票はありません。';

  @override
  String get poll => '投票';

  @override
  String get pollNeedsQuestion => '質問文を入力してください';

  @override
  String get pollNeedsAnswers => '回答を少なくとも2つ設定する必要があります';

  @override
  String get pollEndInPast => '終了日時は未来の日時にしてください。';

  @override
  String get pollQuestion => '質問';

  @override
  String pollAnswer(int number) {
    return '回答$number';
  }

  @override
  String get pollRemoveAnswer => 'この回答を削除';

  @override
  String get pollAddAnswer => '回答を追加';

  @override
  String get pollMultipleChoice => '複数選択を許可する';

  @override
  String get pollChoicesAllowed => '選べる数';

  @override
  String get pollAnyNumber => '制限なし';

  @override
  String get pollPublic => '投票者の一覧をユーザーに開示する';

  @override
  String get pollAllowChangeVote => '投票の変更を許可する';

  @override
  String get pollCloses => '投票の締め切り（任意）';

  @override
  String get pollNeverCloses => 'なし';

  @override
  String get pollHideVotes => '終了まで結果を非表示にする';

  @override
  String get pollHideVotesNeedsEnd => '先に終了日時を選んでください。';

  @override
  String get addPoll => '投票を追加';

  @override
  String get submit => '送信';

  @override
  String get editPoll => '投票を編集';

  @override
  String get removePoll => '投票を削除';

  @override
  String get draftSaved => '保存しました';

  @override
  String get draftSavedWithoutPoll => '下書きを保存しました（下書きには投票を保存できないため、投票は含まれません）。';

  @override
  String get draftNeedsText => '下書きとして保存するには何か入力してください。';

  @override
  String get drafts => '下書き';

  @override
  String get draftsLoadFailed => '下書きを読み込めませんでした';

  @override
  String get noDrafts => '保存した下書きがありません。書きかけの投稿を閉じるときに「下書きを保存」を選ぶと、ここに保存されます。';

  @override
  String draftReplyTo(String title) {
    return '「$title」への返信';
  }

  @override
  String get draftUntitled => '無題のディスカッション';

  @override
  String get deleteDraftQuestion => '下書きを削除してもよろしいですか？';

  @override
  String get deleteDraft => '下書きを削除';
}
