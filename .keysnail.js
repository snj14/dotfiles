// ================ KeySnail Init File ================ //

// この領域は, GUI により初期化ファイルを生成した際にも引き継がれます
// 特殊キー, キーバインド定義, フック, ブラックリスト以外のコードは, この中に書くようにして下さい
//{{%PRESERVE%

// ==================== prefix ==================== //
// エディットモードで C-z を入力すると, ビューモードのキーバインドが使える
// key.keyMapHolder[key.modes.EDIT]["C-z"] = key.keyMapHolder[key.modes.VIEW];

// ==================== set about:config value ==================== //
// util.setPrefs({"ui.key.generalAccessKey" : 0, // kill access key (for Mac User)
//                "ui.caretWidth"           : 5, // Make caret bolder
//                "ui.caretBlinkTime"       : 0  // Stop caret blink
//               });
//}}%PRESERVE%

// ================ Special Keys ====================== //

key.quitKey              = "C-g";
key.helpKey              = "<f1>";
key.escapeKey            = "C-q";
key.macroStartKey        = "Not defined";
key.macroEndKey          = "Not defined";
key.universalArgumentKey = "C-u";
key.negativeArgument1Key = "C--";
key.negativeArgument2Key = "C-M--";
key.negativeArgument3Key = "M--";
key.suspendKey           = "<f2>";

// ================ Hooks ============================= //

hook.setHook('KeyBoardQuit', function (aEvent) {
    command.closeFindBar();
    document.getElementById("Browser:Stop").doCommand();
    if (util.isCaretEnabled()) {
        command.resetMark(aEvent);
    } else {
        goDoCommand("cmd_selectNone");
    }
    key.generateKey(aEvent.originalTarget, KeyEvent.DOM_VK_ESCAPE, true);
    // focus on content
    let elem = document.commandDispatcher.focusedElement;
    if (elem) elem.blur();

    gBrowser.focus();
    content.focus();
});

// ================ Key Bindings ====================== //

key.setGlobalKey('C-M-R', function () {
    userscript.reload();
}, '設定ファイルを再読み込み');

key.setGlobalKey(['<f1>', 'b'], function () {
    key.listKeyBindings();
}, 'キーバインド一覧を表示');

key.setGlobalKey(['<f1>', 'F'], function () {
    openHelpLink("firefox-help");
}, 'Firefox のヘルプを表示');

key.setGlobalKey('C-t', function () {
    document.getElementById("cmd_newNavigatorTab").doCommand();
}, 'タブを開く');

key.setGlobalKey(['C-x', 'j'], function (aEvent) {
    hah.enterStartKey(aEvent);
}, 'LoL を開始');

key.setGlobalKey(['C-x', 'l'], function () {
    command.focusToById("urlbar");
}, 'ロケーションバーへフォーカス', true);

key.setGlobalKey(['C-x', 'g'], function () {
    command.focusToById("searchbar");
}, '検索バーへフォーカス', true);

key.setGlobalKey(['C-x', 't'], function () {
    command.focusElement(command.elementsRetrieverTextarea, 0);
}, '最初のインプットエリアへフォーカス', true);

key.setGlobalKey(['C-x', 's'], function () {
    command.focusElement(command.elementsRetrieverButton, 0);
}, '最初のボタンへフォーカス', true);

key.setGlobalKey(['C-k'], function () {
    var tab = gBrowser.mCurrentTab;
    if (tab.previousSibling) {
        gBrowser.mTabContainer.selectedIndex--;
    }
    gBrowser.removeTab(tab);
    content.focus();
}, 'タブ / ウィンドウを閉じる');

key.setGlobalKey(['C-x', 'k'], function () {
    var tab = gBrowser.mCurrentTab;
    if (tab.previousSibling) {
        gBrowser.mTabContainer.selectedIndex--;
    }
    gBrowser.removeTab(tab);
    content.focus();
}, 'タブ / ウィンドウを閉じる');

key.setGlobalKey(['C-x', 'n'], function () {
    OpenBrowserWindow();
}, 'ウィンドウを開く');

key.setGlobalKey(['C-x', 'C-c'], function () {
    goQuitApplication();
}, 'Firefox を終了');

key.setGlobalKey(['C-x', 'o'], function (aEvent, aArg) {
    command.focusOtherFrame(aArg);
}, '次のフレームを選択', true);

key.setGlobalKey(['C-x', 'C-w'], function () {
    saveDocument(window.content.document);
}, 'ファイルを保存');

key.setGlobalKey(['C-x', 'C-f'], function () {
    BrowserOpenFileWindow();
}, 'ファイルを開く');

key.setGlobalKey(['C-x', '1'], function (aEvent) {
    window.loadURI(aEvent.target.ownerDocument.location.href);
}, '現在のフレームだけを表示');

key.setGlobalKey('C-m', function (aEvent) {
    key.generateKey(aEvent.originalTarget, KeyEvent.DOM_VK_RETURN, true);
}, 'リターンコードを生成');

key.setGlobalKey('M-w', function (aEvent) {
    command.copyRegion(aEvent);
}, '選択中のテキストをコピー');

key.setGlobalKey('C-s', function () {
    command.iSearchForward();
}, 'インクリメンタル検索');

key.setGlobalKey('C-r', function () {
    command.iSearchBackward();
}, '逆方向インクリメンタル検索');

key.setGlobalKey('C-.', function () {
    gBrowser.mTabContainer.advanceSelectedTab(1, true);
    content.focus();
}, 'ひとつ右のタブへ');

key.setGlobalKey('C-,', function () {
    gBrowser.mTabContainer.advanceSelectedTab(-1, true);
    content.focus();
}, 'ひとつ左のタブへ');

key.setGlobalKey(['C-c', 'C-t', 'u'], function () {
    undoCloseTab();
}, '閉じたタブを元に戻す');

key.setGlobalKey(['C-c', 'C-c', 'C-v'], function () {
    toJavaScriptConsole();
}, 'Javascript コンソールを表示');

key.setGlobalKey(['C-c', 'C-c', 'C-c'], function () {
    command.clearConsole();
}, 'Javascript コンソールの表示をクリア');

key.setGlobalKey(['C-c', 'i'], function () {
    BrowserPageInfo();
}, 'ページ情報表示');

key.setGlobalKey('M-R', function () {
    Application.restart();
}, 'Firefox を再起動');

key.setGlobalKey('C-j', function (ev, arg) {
    let elem = document.commandDispatcher.focusedElement;
    if (elem) elem.blur();

    gBrowser.focus();
    content.focus();
}, 'focus content area');

key.setGlobalKey(['C-x', 'b'], function (ev, arg) {
    toggleSidebar("viewBookmarksSidebar");
}, 'viewBookmarksSidebar', true);

key.setGlobalKey(['C-x', 'd'], function (ev, arg) {
    toggleSidebar("viewDownloadsSidebar");
}, 'viewDownloadsSidebar', true);

key.setGlobalKey(['C-x', 'a'], function (ev, arg) {
    toggleSidebar("viewAddonsSidebar");
}, 'viewAddonsSidebar', true);

key.setGlobalKey(['C-x', 'h'], function (ev, arg) {
    toggleSidebar("viewHistorySidebar");
}, 'viewHistorySidebar', true);

key.setViewKey('s', function (aEvent) {
    setStyleDisabled(!getMarkupDocumentViewer().authorStyleDisabled);
}, 'ToggleStyleSheet');

key.setViewKey('C-n', function (aEvent) {
    key.generateKey(aEvent.originalTarget, KeyEvent.DOM_VK_DOWN, true);
}, '一行スクロールダウン');

key.setViewKey('C-p', function (aEvent) {
    key.generateKey(aEvent.originalTarget, KeyEvent.DOM_VK_UP, true);
}, '一行スクロールアップ');

key.setViewKey('C-f', function (aEvent) {
    key.generateKey(aEvent.originalTarget, KeyEvent.DOM_VK_RIGHT, true);
}, '右へスクロール');

key.setViewKey('C-b', function (aEvent) {
    key.generateKey(aEvent.originalTarget, KeyEvent.DOM_VK_LEFT, true);
}, '左へスクロール');

key.setViewKey([['>'], ['.']], function () {
    goDoCommand("cmd_scrollRight");
}, '右へスクロール');

key.setViewKey([['<'], [',']], function () {
    goDoCommand("cmd_scrollLeft");
}, '左へスクロール');

key.setViewKey(['M-v'], function () {
    goDoCommand("cmd_scrollPageUp");
}, '一画面分スクロールアップ');

key.setViewKey('C-v', function () {
    goDoCommand("cmd_scrollPageDown");
}, '一画面スクロールダウン');

key.setViewKey('SPC', function () {
    goDoCommand("cmd_scrollLineDown");
    goDoCommand("cmd_scrollLineDown");
    goDoCommand("cmd_scrollLineDown");
    goDoCommand("cmd_scrollLineDown");
    goDoCommand("cmd_scrollLineDown");
}, '5行スクロールダウン');

key.setViewKey([['g'], ['M-<']], function () {
    goDoCommand("cmd_scrollTop");
}, 'ページ先頭へ移動');

key.setViewKey([['G'], ['M->']], function () {
    goDoCommand("cmd_scrollBottom");
}, 'ページ末尾へ移動');

key.setViewKey('R', function (aEvent) {
    BrowserReload();
}, '更新');

// key.setViewKey('B', function (aEvent) {
//     BrowserBack();
// }, '戻る');

key.setViewKey('F', function (aEvent) {
    BrowserForward();
}, '進む');

key.setViewKey('l', function () {
    gBrowser.mTabContainer.advanceSelectedTab(1, true);
}, 'ひとつ右のタブへ');

key.setViewKey('h', function () {
    gBrowser.mTabContainer.advanceSelectedTab(-1, true);
}, 'ひとつ左のタブへ');

key.setViewKey('M-n', function () {
    command.walkInputElement(command.elementsRetrieverButton, true, true);
}, '次のボタンへフォーカスを当てる');

key.setViewKey('M-p', function () {
    command.walkInputElement(command.elementsRetrieverButton, false, true);
}, '前のボタンへフォーカスを当てる');

key.setViewKey('f', function () {
    command.focusElement(command.elementsRetrieverTextarea, 0);
}, '最初のインプットエリアへフォーカス', true);

key.setEditKey([['C-SPC'], ['C-@']], function (aEvent) {
    command.setMark(aEvent);
}, 'マークをセット');

key.setEditKey('C-o', function (aEvent) {
    command.openLine(aEvent);
}, '行を開く (open line)');

key.setEditKey([['C-x', 'u'], ['C-/']], function () {
    display.echoStatusBar("Undo!", 2000);
    goDoCommand("cmd_undo");
}, 'アンドゥ');

key.setEditKey(['C-x', 'r', 'd'], function (aEvent, aArg) {
    command.replaceRectangle(aEvent.originalTarget, "", false, !aArg);
}, '矩形削除', true);

key.setEditKey(['C-x', 'r', 't'], function (aEvent) {
    prompt.read("String rectangle: ", function (aStr, aInput) {command.replaceRectangle(aInput, aStr);}, aEvent.originalTarget);
}, '矩形置換', true);

key.setEditKey(['C-x', 'r', 'o'], function (aEvent) {
    command.openRectangle(aEvent.originalTarget);
}, '矩形行空け', true);

key.setEditKey(['C-x', 'r', 'k'], function (aEvent, aArg) {
    command.kill.buffer = command.killRectangle(aEvent.originalTarget, !aArg);
}, '矩形 kill', true);

key.setEditKey(['C-x', 'r', 'y'], function (aEvent) {
    command.yankRectangle(aEvent.originalTarget, command.kill.buffer);
}, '矩形 yank', true);

key.setEditKey(['C-x', 'h'], function (aEvent) {
    command.selectAll(aEvent);
}, '全て選択');

key.setEditKey('M-/', function () {
    display.echoStatusBar("Redo!", 2000);
    goDoCommand("cmd_redo");
}, 'リドゥ');

key.setEditKey('C-a', function (aEvent) {
    command.beginLine(aEvent);
}, '行頭へ移動');

key.setEditKey('C-e', function (aEvent) {
    command.endLine(aEvent);
}, '行末へ');

key.setEditKey('C-f', function (aEvent) {
    command.nextChar(aEvent);
}, '一文字右へ移動');

key.setEditKey('C-b', function (aEvent) {
    command.previousChar(aEvent);
}, '一文字左へ移動');

key.setEditKey('M-f', function (aEvent) {
    command.nextWord(aEvent);
}, '一単語右へ移動');

key.setEditKey('M-b', function (aEvent) {
    command.previousWord(aEvent);
}, '一単語左へ移動');

key.setEditKey('C-n', function (aEvent) {
    command.nextLine(aEvent);
}, '一行下へ');

key.setEditKey('C-p', function (aEvent) {
    command.previousLine(aEvent);
}, '一行上へ');

key.setEditKey('C-v', function (aEvent) {
    command.pageDown(aEvent);
}, '一画面分下へ');

key.setEditKey('M-v', function (aEvent) {
    command.pageUp(aEvent);
}, '一画面分上へ');

key.setEditKey('M-<', function (aEvent) {
    command.moveTop(aEvent);
}, 'テキストエリア先頭へ');

key.setEditKey('M->', function (aEvent) {
    command.moveBottom(aEvent);
}, 'テキストエリア末尾へ');

key.setEditKey('C-d', function () {
    goDoCommand("cmd_deleteCharForward");
}, '次の一文字削除');

key.setEditKey('C-h', function () {
    goDoCommand("cmd_deleteCharBackward");
}, '前の一文字を削除');

key.setEditKey('M-d', function () {
    goDoCommand("cmd_deleteWordForward");
}, '次の一単語を削除');

key.setEditKey([['M-h'], ['C-<backspace>']], function () {
    goDoCommand("cmd_deleteWordBackward");
}, '前の一単語を削除');

key.setEditKey('M-u', function (aEvent) {
    command.processForwardWord(aEvent.originalTarget, function (aString) {return aString.toUpperCase();});
}, '次の一単語を全て大文字に (Upper case)');

key.setEditKey('M-l', function (aEvent) {
    command.processForwardWord(aEvent.originalTarget, function (aString) {return aString.toLowerCase();});
}, '次の一単語を全て小文字に (Lower case)');

key.setEditKey('M-c', function (aEvent) {
    command.processForwardWord(aEvent.originalTarget, command.capitalizeWord);
}, '次の一単語をキャピタライズ');

key.setEditKey('C-k', function (aEvent) {
    command.killLine(aEvent);
}, 'カーソルから先を一行カット');

key.setEditKey('C-y', command.yank, 'クリップボードの中身を貼り付け');

key.setEditKey('M-y', command.yankPop, '以前に貼り付けた中身を順に貼り付け');

key.setEditKey('C-M-y', function (aEvent) {
    if (!command.kill.ring.length) {
        return;
    }
    var clipboardText = command.getClipboardText();
    if (clipboardText != command.kill.ring[0]) {
        command.pushKillRing(clipboardText);
    }
    prompt.read("Text to paste:", function (aReadStr) {if (aReadStr) {key.insertText(aReadStr);}}, null, command.kill.ring, command.kill.ring[0], 0, "clipboard");
}, '以前にコピーしたテキスト一覧から選択して貼り付け');

key.setEditKey('C-w', function (aEvent) {
    goDoCommand("cmd_copy");
    goDoCommand("cmd_delete");
    command.resetMark(aEvent);
}, 'リージョンをカット');

key.setEditKey('M-n', function () {
    command.walkInputElement(command.elementsRetrieverTextarea, true, true);
}, '次のテキストエリアへフォーカス');

key.setEditKey('M-p', function () {
    command.walkInputElement(command.elementsRetrieverTextarea, false, true);
}, '前のテキストエリアへフォーカス');

key.setCaretKey([['C-n'], ['j']], function (aEvent) {
    aEvent.target.ksMarked ? goDoCommand("cmd_selectLineNext") : goDoCommand("cmd_scrollLineDown");
}, '一行下へ');

key.setCaretKey([['C-p'], ['k']], function (aEvent) {
    aEvent.target.ksMarked ? goDoCommand("cmd_selectLinePrevious") : goDoCommand("cmd_scrollLineUp");
}, '一行上へ');

key.setCaretKey([['C-f'], ['l']], function (aEvent) {
    aEvent.target.ksMarked ? goDoCommand("cmd_selectCharNext") : goDoCommand("cmd_scrollRight");
}, '一文字右へ移動');

key.setCaretKey([['C-b'], ['h'], ['C-h']], function (aEvent) {
    aEvent.target.ksMarked ? goDoCommand("cmd_selectCharPrevious") : goDoCommand("cmd_scrollLeft");
}, '一文字左へ移動');

key.setCaretKey('>', function () {
    goDoCommand("cmd_scrollRight");
}, '右へスクロール');

key.setCaretKey('.', function () {
    util.getSelectionController().scrollHorizontal(false);
}, 'ページを右へスクロール');

key.setCaretKey('<', function () {
    goDoCommand("cmd_scrollLeft");
}, '左へスクロール');

key.setCaretKey(',', function () {
    util.getSelectionController().scrollHorizontal(true);
}, 'ページを左へスクロール');

key.setCaretKey([['b'], ['M-v']], function (aEvent) {
    aEvent.target.ksMarked ? goDoCommand("cmd_selectPagePrevious") : goDoCommand("cmd_movePageUp");
}, '一画面分上へ');

key.setCaretKey([['C-v'], ['SPC']], function (aEvent) {
    aEvent.target.ksMarked ? goDoCommand("cmd_selectPageNext") : goDoCommand("cmd_movePageDown");
}, '一画面分下へ');

key.setCaretKey([['g'], ['M-<']], function (aEvent) {
    aEvent.target.ksMarked ? goDoCommand("cmd_selectTop") : goDoCommand("cmd_scrollTop");
}, 'ページ先頭へ移動');

key.setCaretKey([['G'], ['M->']], function (aEvent) {
    aEvent.target.ksMarked ? goDoCommand("cmd_selectBottom") : goDoCommand("cmd_scrollBottom");
}, 'ページ末尾へ移動');

key.setCaretKey('R', function (aEvent) {
    BrowserReload();
}, '更新');

key.setCaretKey('B', function (aEvent) {
    BrowserBack();
}, '戻る');

key.setCaretKey('F', function (aEvent) {
    BrowserForward();
}, '進む');

key.setCaretKey(['C-x', 'h'], function () {
    goDoCommand("cmd_selectAll");
}, 'すべて選択');

key.setCaretKey('M-n', function () {
    command.walkInputElement(command.elementsRetrieverButton, true, true);
}, '次のボタンへフォーカスを当てる');

key.setCaretKey('M-p', function () {
    command.walkInputElement(command.elementsRetrieverButton, false, true);
}, '前のボタンへフォーカスを当てる');

key.setCaretKey('f', function () {
    command.focusElement(command.elementsRetrieverTextarea, 0);
}, '最初のインプットエリアへフォーカス', true);

key.setCaretKey([['C-SPC'], ['C-@']], function (aEvent) {
    command.setMark(aEvent);
}, 'マークをセット');

key.setCaretKey([['C-a'], ['^']], function (aEvent) {
    aEvent.target.ksMarked ? goDoCommand("cmd_selectBeginLine") : goDoCommand("cmd_beginLine");
}, '行頭へ移動');

key.setCaretKey([['C-e'], ['$']], function (aEvent) {
    aEvent.target.ksMarked ? goDoCommand("cmd_selectEndLine") : goDoCommand("cmd_endLine");
}, '行末へ移動');

key.setCaretKey([['M-f'], ['w']], function (aEvent) {
    aEvent.target.ksMarked ? goDoCommand("cmd_selectWordNext") : goDoCommand("cmd_wordNext");
}, '一単語右へ移動');

key.setCaretKey([['M-b'], ['W']], function (aEvent) {
    aEvent.target.ksMarked ? goDoCommand("cmd_selectWordPrevious") : goDoCommand("cmd_wordPrevious");
}, '一単語左へ移動');

key.setCaretKey('J', function () {
    util.getSelectionController().scrollLine(true);
}, '画面を一行分下へスクロール');

key.setCaretKey('K', function () {
    util.getSelectionController().scrollLine(false);
}, '画面を一行分上へスクロール');

key.setCaretKey('z', function (aEvent) {
    command.recenter(aEvent);
}, 'カーソル位置へスクロール');

key.setCaretKey('L', function () {
    gBrowser.mTabContainer.advanceSelectedTab(1, true);
}, 'ひとつ右のタブへ');

key.setCaretKey('H', function () {
    gBrowser.mTabContainer.advanceSelectedTab(-1, true);
}, 'ひとつ左のタブへ');

key.setViewKey("C-;", function (ev, arg) {
                   ext.exec("tanything", arg);
               }, "タブを一覧表示", true);
