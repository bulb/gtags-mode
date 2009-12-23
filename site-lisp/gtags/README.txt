■gtags.lについて
  このgtags.l は、GNU GLOBAL用のgtags.elを
  xyzzy用に移植したものです。


■ライセンス
  GPL(GNU General Public License)

■インストール
●NetInstallerの場合
 次のマニュアルインストールを飛ばして、下記初期設定を設定してください。

●マニュアルインストールの場合
  ◇1
    gtagsフォルダをsite-lispフォルダにコピーして下さい。

  ◇2
    当ファイルの他にGNU GLOBALのインストールが必要です。
    本家から http://www.gnu.org/software/global/
    win32版をダウンロードして、
    PATHが通っているフォルダに解凍してください。

    Emacs電子書棚さんが参考になります。
    http://www.bookshelf.jp/soft/meadow_42.html#SEC621

  ◇3
    下記の初期設定の前に下記を付けてください。
(export 'ed::gtags-mode "ed")
(autoload 'ed::gtags-mode "gtags/gtags" t)
(require "gtags/gtags-menu")



■初期設定
  .xyzzy か siteinit.l に下記を追加して下さい。
  下記設定(オリジナル)のままですと、C-t とか M-rなどのキーバインドが潰れてしまうので、
  お好みのキーバインドに変更して下さい。

;;; Emacs Lisp 移植キット
(require "elisp")

;;; gtags-mode
(in-package "editor")
(setq *gtags-mode-hook*
      #'(lambda ()
          (local-set-key #\M-t 'gtags-find-tag)
          (local-set-key #\M-r 'gtags-find-rtag)
          (local-set-key #\M-s 'gtags-find-symbol)
          (local-set-key #\M-e 'gtags-find-tag-from-here)
          ;(local-set-key #\M-a 'gtags-pop-stack)
          (local-set-key #\C-t 'gtags-pop-stack)
          (local-set-key #\M-j 'gtags-find-with-grep)
          (local-set-key #\M-c 'gtags-find-file-ext)
          (local-set-key #\M-n 'gtags-find-next-tag)
          (local-set-key #\M-p 'gtags-find-previous-tag)
          (local-set-key #\M-. 'gtags-toggle-source)
          ))

(setq *gtags-select-mode-hook*
      #'(lambda ()
          (local-set-key #\M-a 'gtags-pop-stack)
          (local-set-key #\PageUp 'previous-page-kept-selection)
          (local-set-key #\PageDown 'next-page-kept-selection)
          (local-set-key #\LBtnDown 'gtags-mouse-left-press)
          (local-set-key #\M-n #'(lambda ()
                                   (interactive)
                                   (next-virtual-line)
                                   (gtags-select-tag)))
          (local-set-key #\M-p #'(lambda ()
                                   (interactive)
                                   (previous-virtual-line)
                                   (gtags-select-tag)))
          ))

(add-hook '*c-mode-hook*
          #'(lambda ()
              (gtags-mode 1)
              ;(gtags-make-complete-list);未対応
              ))
(add-hook '*c++-mode-hook*
          #'(lambda ()
              (gtags-mode 1)))
(add-hook '*php-mode-hook*
          #'(lambda ()
              (gtags-mode 1)))
(in-package "user")


■使い方
●1 GTAGSの生成方法
  ◇メニュー
  ツールメニューにある「GTAGSファイルの作成」を選択。
  タグを作成したいソースディレクトリに移動して
  OKを押すと生成されます。

  1.生成するディレクトリにGTAGSファイルがない場合は新規に生成。
  2.すでにGTAGSファイルが存在している場合はIncrementalにアップデート
  つまり修正したソースだけTAGファイルを更新します。

  ◇コマンドラインから生成する場合
  > cd source    ;タグを作りたいソースディレクトリに移動
  > gtags -v     ;GTAGSを生成

  xyzzyからは、C-x & や ファイラーのF3 から
  > gtags
  とタイプすることで生成することができます。

  更新したファイルだけを反映させたい場合は、
  > global -u

●2 ジャンプのキーバインド
  M-t 関数の定義元へジャンプ
  M-r 関数を参照元の一覧を表示。RET で参照元へジャンプ
  M-s 変数の定義元と参照元の一覧を表示。RET で該当箇所へジャンプ
  M-e gtags-select-modeバッファを経由せずに、ダイレクトジャンプ
  C-t 前のバッファへ戻る
  M-j 参照元の一覧を表示(grepを使用)
  M-c カーソル直下にあるヘッダファイルにジャンプ(C/C++のみ)
  M-n 次の候補へ移動
  M-p 前の候補へ移動
  M-. .c <--> .hファイルをトグルする(C/C++のみ)


■更新履歴
  2007/12/27
  ・emacs.l依存の解消(NANRIさん提供)
  ・gtags-find-tag-by-event(サポート外)あたりを修正
    バイトコンパイルが通るように修正。
  ・README.txtの添付

  2007/07/21
  ・gtags-menu.lのバグ修正。
    ディレクトリ指定の仕方をミスっていた。
  ・niup記念

  2006/11/14
  ・gtags-ext.lにgtags-toggle-sourceを追加。
    elispのtoggle-source.elを参考にしました。

  2006/11/01
  ・gtags-menu.lの引数間違いを修正(OHKUBOさん指摘 orz)

  2006/08/26
  ・gtags-menu.lを修正。更新か生成かを選択できるように追加。

  2006/08/13
  ・gtags-menu.l内のtypoを修正(キャンセルの不具合)。

  2006/08/10
  ・使い方などを追加。
  ・gtags-ext.lの作成。
  ・(in-package "editor")に対応。

  2006/08/07
  ・NetInstaller対応

  2005/09/05
  ・作りかけのファイルをrequireしていたのを削除。
  ・gtags-select-mode時のキーバインドをオリジナルに合わせた。

  2005/08/04
  ・とりあえずα版リリース。


■お問い合わせ
  ttomise@gmail.com

