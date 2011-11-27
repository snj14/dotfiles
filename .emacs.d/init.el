;; last updated : 2011-09-29
(defconst my-time-zero (current-time))
(defvar my-time-list nil)

(defun my-time-lag-calc (lag label)
  (if (assoc label my-time-list)
      (setcdr (assoc label my-time-list)
              (- lag (cdr (assoc label my-time-list))))
    (setq my-time-list (cons (cons label lag) my-time-list))))

(defun my-time-lag (label)
  (let* ((now (current-time))
         (min (- (car now) (car my-time-zero)))
         (sec (- (car (cdr now)) (car (cdr my-time-zero))))
         (msec (/ (- (car (cdr (cdr now)))
                     (car (cdr (cdr my-time-zero))))
                  1000))
         (lag (+ (* 60000 min) (* 1000 sec) msec)))
    (my-time-lag-calc lag label)))

(defun my-time-lag-print ()
  (message (prin1-to-string
            (sort my-time-list
                  (lambda  (x y)  (> (cdr x) (cdr y)))))))

;;; ------------------------------------------------------------------
;;; function
;;; ------------------------------------------------------------------
(eval-when-compile (require 'cl))

(dolist (ver '("22" "23" "23.0" "23.1" "23.2"))
  (set (intern (concat "emacs" ver "-p"))
       (if (string-match (concat "^" ver) emacs-version)
           t nil)))

(defmacro req (lib src &rest body)
  `(cond ((locate-library ,(symbol-name lib))
          (my-time-lag ,(symbol-name lib))
          (require ',lib nil t)
          ,@body
          (my-time-lag ,(symbol-name lib))
          )
         ((not ,src)
          (message (format "library not found : %S" (symbol-name ',lib))))
         ((string-match "^http" ,src)
          (message (format "(auto-install-from-url %S)" ,src)))
         (t
          (message (format "(auto-install-batch %S)" ,src)))))

(defmacro lazyload (func lib src &rest body)
  `(cond ((locate-library ,lib)
          ,@(mapcar (lambda (f) `(autoload ',f ,lib nil t)) func)
          (eval-after-load ,lib
            '(progn
               ,@body)))
         ((not ,src)
          (message (format "library not found : %S" ,lib)))
         ((string-match "^http" ,src)
          (message (format "(auto-install-from-url %S)" ,src)))
         (t
          (message (format "(auto-install-batch %S)" ,src)))))

;; system-type predicates
(setq darwin-p  (eq system-type 'darwin)
      ns-p      (eq window-system 'ns)
      carbon-p  (featurep 'carbon-emacs-package)
      linux-p   (eq system-type 'gnu/linux)
      cygwin-p  (eq system-type 'cygwin)
      nt-p      (eq system-type 'windows-nt)
      meadow-p  (featurep 'meadow)
      windows-p (or cygwin-p nt-p meadow-p))
;; verification
;; (mapcar (lambda (x) (if (boundp x) (symbol-value x) 'none))
;;   '(emacs22-p emacs23-p emacs23.0-p emacs23.1-p emacs23.2-p emacs23.3-p))

;;; ------------------------------------------------------------------
;;; env
;;; ------------------------------------------------------------------

;; private ?
(setq emacs-private-p (or darwin-p linux-p))

;; load-path
(add-to-list 'load-path "~/.emacs.d/")
(add-to-list 'load-path "~/.emacs.d/auto-install")

;;; auto-install.el
(lazyload (auto-install-from-url
           auto-install-from-emacswiki
           auto-install-from-dired
           auto-install-from-directory
           auto-install-from-buffer
           auto-install-from-gist
           auto-install-batch)
  "auto-install" "http://www.emacswiki.org/emacs/download/auto-install.el"
  ;; (setq url-proxy-services '(("http" . "PROXY:8080")))
  )


;;; change default key bindings
(global-set-key (kbd "C-x k") 'kill-this-buffer)
(global-set-key (kbd "C-h")   'backward-delete-char-untabify); h => delete backward
(global-set-key (kbd "M-h")   'backward-kill-word)
(global-set-key (kbd "M-C-h") 'backward-kill-sexp)
(global-set-key (kbd "M-C-d") 'kill-sexp); d => delete forward
(global-set-key (kbd "C-m")   'indent-new-comment-line)
; (global-set-key (kbd "M-a")   'back-to-indentation); a => goto beginning of line
(global-set-key (kbd "C-c q") 'comment-region)
(global-unset-key (kbd "M-ESC"))
(global-set-key (kbd "M-ESC") 'eval-expression); xyzzy like
(global-set-key (kbd "M-g") 'goto-line) ; goto-lineをM-gに
; font size
(global-set-key (kbd "C-+") (lambda () (interactive) (text-scale-increase 1)))
(global-set-key (kbd "C--") (lambda () (interactive) (text-scale-decrease 1)))
(global-set-key (kbd "C-0") (lambda () (interactive) (text-scale-increase 0)))
;; C-v
(defadvice scroll-up (around wzlike-scroll-up activate)
  (condition-case err
      ad-do-it
    (end-of-buffer
     (goto-char (point-max)))))
;; M-v
(defadvice scroll-down (around wzlike-scroll-down activate)
  (condition-case err
      ad-do-it
    (beginning-of-buffer
     (goto-char (point-min)))))

;; fullscreen
(defun toggle-fullscreen ()
  (interactive)
  (if (frame-parameter nil 'fullscreen)
      (set-frame-parameter nil 'fullscreen nil)
    (set-frame-parameter nil 'fullscreen 'fullboth)))
(global-set-key (kbd "C-c m") 'toggle-fullscreen)

;;; ------------------------------------------------------------------
;;; Color
;;; ------------------------------------------------------------------

;; 色の設定
(when linux-p
  (set-frame-parameter nil 'alpha 80)
  (when window-system
    (add-hook 'after-init-hook 'server-start)
    (setq x-select-enable-clipboard t))
   (setq color-theme-libraries "~/.emacs.d")
  (load-library "color-theme-library")
  (color-theme-arjen)

;;   (my-color-theme)
  )

;;; ------------------------------------------------------------------
;;; Font
;;; ------------------------------------------------------------------
(when window-system

  (cond
   ;; X / emacs22
   ((and (eq window-system 'x)
	 (= emacs-major-version 22))
    (dolist (fspec '("-*-fixed-medium-r-normal--12-*-*-*-*-*-fontset-12"
		     "-*-fixed-medium-r-normal--14-*-*-*-*-*-fontset-14"
		     "-*-fixed-medium-r-normal--16-*-*-*-*-*-fontset-16"
		     "-*-fixed-medium-r-normal--18-*-*-*-*-*-fontset-18"))
      (if (not (assoc fspec fontset-alias-alist))
          (create-fontset-from-fontset-spec fspec)))
    (add-to-list 'default-frame-alist '(font . "fontset-14") t))

   ;; Emacs 23 以上
   ((>= emacs-major-version 23)
    (let (my-font-height my-font my-font-ja)
      (cond
       ;; for X (debian/ubuntu/fedora)
       ((eq window-system 'x)
	;;(setq my-font-height 90)
	;; (setq my-font-height 105)
	;; (setq my-font-height 120)
	;; (setq my-font-height 150)
	(setq my-font-height 180)
	;;(setq my-font "Monospace")
	;;(setq my-font "Inconsolata")
        (setq my-font "ricty")
;;         (setq my-font-ja "ricty")

	;; (setq my-font "Takaoゴシック")
        ;; (setq my-font-ja "Takaoゴシック")
	;;(setq my-font-ja "VL ゴシック")
	;;(setq my-font-ja "Takaoゴシック")
	;; (setq my-font-ja "IPAゴシック")

	;; (setq face-font-rescale-alist
	;;       '(("-cdac$" . 1.3)))

	;; VMware 上のX11では、800x600 のとき 96 dpi になるように調節されている。
	;; なので、別のサイズやフルスクリーンにすると、dpi の値が変化する。
	;; 結果、Emacs Xft では同じ pt に対するpixel値が大きくなってしまう。
	;; 対処不明。。。
	)

       ;; Cocoa Emacs
       ((eq window-system 'ns)
	(setq mac-allow-anti-aliasing t)
	(setq my-font-height 120)
	;;(setq my-font "Courier")
	;;(setq my-font "Courier New")
	;;(setq my-font "Osaka-Mono")
	;;(setq my-font "Monaco")       ;; XCode 3.1 で使っているフォント
	(setq my-font "Menlo")        ;; XCode 3.2 で使ってるフォント
	(setq my-font-ja "Hiragino Kaku Gothic Pro")
	;;(setq my-font-ja "Hiragino Maru Gothic Pro")
	;;(setq my-font-ja "IPAゴシック")

	;; フォントサイズの微調節 (12ptで合うように)
	(setq face-font-rescale-alist
	      '(("^-apple-hiragino.*" . 1.2)
		(".*osaka-bold.*" . 1.2)
		(".*osaka-medium.*" . 1.2)
		(".*courier-bold-.*-mac-roman" . 1.0)
		(".*monaco cy-bold-.*-mac-cyrillic" . 0.9)
		(".*monaco-bold-.*-mac-roman" . 0.9)
		("-cdac$" . 1.3)))
	)

       ;; NTEmacs
       ((eq window-system 'w32)
	(setq scalable-fonts-allowed t)
	(setq w32-enable-synthesized-fonts t)
	(setq my-font-height 100)
	;;(setq my-font "ＭＳ ゴシック")
	;;(setq my-font "VL ゴシック")
	;;(setq my-font "IPAゴシック")
	;;(setq my-font "Takaoゴシック")
	;;(setq my-font "Inconsolata")
	(setq my-font "Consolas")
	;;(setq my-font "DejaVu Sans Mono")
	;;(setq my-font-ja "ＭＳ ゴシック")
	;;(setq my-font-ja "VL ゴシック")
	(setq my-font-ja "IPAゴシック")
	;;(setq my-font-ja "Takaoゴシック")
	;;(setq my-font-ja "メイリオ")
	;; ime-font の設定がわからん

	;; フォントサイズの微調節 (10ptで合うように)
	(setq face-font-rescale-alist
	      '((".*ＭＳ.*bold.*iso8859.*"  . 0.9)
		(".*ＭＳ.*bold.*jisx02.*" . 0.95)
		(".*DejaVu Sans.*" . 0.9)
		(".*メイリオ.*" . 1.1)
		("-cdac$" . 1.3)))

	;;(dolist (e face-font-rescale-alist)
	;;  (setcar e (encode-coding-string (car e) 'emacs-mule)))
	)

       )

      ;; デフォルトフォント設定
      (when my-font
	(set-face-attribute 'default nil :family my-font :height my-font-height)
	(set-frame-font (format "%s-%d" my-font (/ my-font-height 10)))
	)

      ;; 日本語文字に別のフォントを指定
      (when my-font-ja
	  (let ((fn (frame-parameter nil 'font))
		(rg "iso10646-1"))
	    (set-fontset-font fn 'katakana-jisx0201 `(,my-font-ja . ,rg))
	    (set-fontset-font fn 'japanese-jisx0208 `(,my-font-ja . ,rg))
	    (set-fontset-font fn 'japanese-jisx0212 `(,my-font-ja . ,rg)))
	)
      ))
   ))
;; mac
(when darwin-p
  (add-to-list 'exec-path "/opt/local/bin")
  ;; setting of emacsclient when use screen
  (when (= 2 (length (split-string (shell-command-to-string "pgrep emacs") "\n")))
    (add-hook 'after-init-hook 'server-start)
    (add-hook 'server-done-hook
              (lambda ()
                (shell-command
                 "screen -r -X select `cat ~/tmp/emacsclient-caller`"))))
  (when (or carbon-p
            ns-p)
    (set-frame-parameter nil 'alpha 85);; 透明度
    (load "256color-hack.el")
    (require 'color-theme)
    (color-theme-initialize)
    (my-color-theme))
  (when ns-p
    (prefer-coding-system 'utf-8-unix)
    (create-fontset-from-fontset-spec
     "-*-*-medium-r-normal--14-*-*-*-*-*-fontset-hiramaru14" nil t)
    (create-fontset-from-fontset-spec
     "-*-*-medium-r-normal--16-*-*-*-*-*-fontset-hiramaru16" nil t)
    (create-fontset-from-fontset-spec
     "-*-*-medium-r-normal--20-*-*-*-*-*-fontset-hiramaru20" nil t)
    (mapc
     #'(lambda (fontset)
         (set-fontset-font fontset 'japanese-jisx0208
                           '("Hiragino Maru Gothic Pro" . "iso10646-1"))
         (set-fontset-font fontset 'katakana-jisx0201
                           '("Hiragino Maru Gothic Pro" . "iso10646-1"))
         (set-fontset-font fontset 'japanese-jisx0212
                           '("Hiragino Maru Gothic Pro" . "iso10646-1"))
         ) (list "fontset-hiramaru20" "fontset-hiramaru16" "fontset-hiramaru14"))
    (let (
          ;; (my-fontset "fontset-hiramaru14") ;; ちっちゃいフォント
          (my-fontset "fontset-hiramaru20")  ;; でっかいフォント
          )
      (set-default-font my-fontset)
      (add-to-list 'default-frame-alist `(font . ,my-fontset)))
    )
)
(when nt-p
  ;; 日本語環境の設定
  (set-language-environment "Japanese")
  (set-keyboard-coding-system 'japanese-shift-jis)

  ;; UTF-8⇔Legacy Encoding (EUC-JP や Shift_JIS など)をWindowsで変換
  ;;http://nijino.homelinux.net/emacs/emacs23-ja.html
  ;; encode-translation-table の設定
  (coding-system-put 'euc-jp :encode-translation-table
                     (get 'japanese-ucs-cp932-to-jis-map 'translation-table))
  (coding-system-put 'iso-2022-jp :encode-translation-table
                     (get 'japanese-ucs-cp932-to-jis-map 'translation-table))
  (coding-system-put 'cp932 :encode-translation-table
                     (get 'japanese-ucs-jis-to-cp932-map 'translation-table))
  ;; charset と coding-system の優先度設定
  (set-charset-priority 'ascii 'japanese-jisx0208 'latin-jisx0201
                        'katakana-jisx0201 'iso-8859-1 'cp1252 'unicode)
  (set-coding-system-priority 'utf-8 'euc-jp 'iso-2022-jp 'cp932)
  ;; font
  (set-default-font "Osaka－等幅")
  ;; status bar
  (w32-ime-initialize)
  ;; current directory
  (cd "~")

  ;;ime の ON/OFF でカーソルの色を変える
  (set-cursor-color "snow1")
  (add-hook 'input-method-activate-hook
            (function (lambda () (set-cursor-color "green"))))
  (add-hook 'input-method-inactivate-hook
            (function (lambda () (set-cursor-color "snow1"))))
  ;; タブ, 全角スペースを表示する
  (defface my-face-b-1 '((t (:background "gray15"))) nil)
  (defface my-face-b-2 '((t (:background "gray26"))) nil)
  (defface my-face-u-1 '((t (:foreground "SteelBlue" :underline t))) nil)
  (defvar my-face-b-1 'my-face-b-1)
  (defvar my-face-b-2 'my-face-b-2)
  (defvar my-face-u-1 'my-face-u-1)
  (defadvice font-lock-mode (before my-font-lock-mode ())
    (font-lock-add-keywords
     major-mode
     '(("\t" 0 my-face-b-2 append)
       ("　" 0 my-face-b-1 append)
       ("[ \t]+$" 0 my-face-u-1 append)
       )))
  (ad-enable-advice 'font-lock-mode 'before 'my-font-lock-mode)
  (ad-activate 'font-lock-mode)
  )

;;; other options
(setq inhibit-startup-message t)
(menu-bar-mode -1)     ; hide menu bar
(tool-bar-mode -1)     ; hide tool bar
(line-number-mode 1)   ; show line number   @ mode-line
(column-number-mode 1) ; show column number @ mode-line
(show-paren-mode t)    ;
(setq ring-bell-function 'ignore) ; DO NOT BEEP!!!
(blink-cursor-mode nil); cursor, do not blink
(fset 'yes-or-no-p 'y-or-n-p) ; yes/no -> y/n
(setq delete-auto-save-files t)
(setq kill-whole-line t)  ; kill line
(setq kill-read-only-ok t); kill line
(put 'narrow-to-region 'disabled nil) ; enable narrowing
(setq resize-minibuffer-mode 1)
(setq require-final-newline t)
(setq transient-mark-mode t); enable visual feedback on selections
(setq frame-title-format (concat  "%b - emacs@" system-name)); default to better frame titles
(setq-default indent-tabs-mode nil) ; use space for indent
;(add-hook 'before-save-hook 'delete-trailing-whitespace); auto delete trail whitespace
(when (boundp 'show-trailing-whitespace);; emphasize trailing whitespace
 (setq-default show-trailing-whitespace t))
(setq-default truncate-lines t);;テキストを折り返さない
(setq truncate-partial-width-windows t)
(setq-default indicate-empty-lines t)      ;; emphasize EOF (for GUI)
(setq-default indicate-buffer-boundaries t);; emphasize EOF (for GUI)
(set-face-foreground 'fringe "IndianRed")  ;; fringe
(set-face-background 'fringe "gray10")     ;; fringe
(setq undo-limit 100000)
(setq scroll-step 1) ;; scrollは1行ずつ
(setq read-file-name-completion-ignore-case t) ;; file-nameの補完は大文字小文字関係なく


;;; ------------------------------------------------------------------
;;; Anything
;;; ------------------------------------------------------------------

;; anything.el
(req anything "anything"
  (setq anything-idle-delay 0.3)
  (setq anything-input-idle-delay 0)
  (setq anything-selection-face 'anything-isearch-match)

  (define-key anything-map (kbd "M-n") 'anything-next-source)
  (define-key anything-map (kbd "M-p") 'anything-previous-source)

  ;; anything-config.el
  (require 'anything-config nil t)

  ;; color
  (set-face-background 'anything-isearch-match "red4")
  (set-face-foreground 'anything-file-name "grey")

  ;; anything-match-plugin.el
  (require 'anything-match-plugin nil t)

  (require 'anything-show-completion nil t)

  ;; descbinds-anything.el
  (when (require 'descbinds-anything nil t)
    (descbinds-anything-install))

  ;; ちら見用
  (define-key anything-map (kbd "C-o") 'anything-execute-persistent-action)

  (global-set-key (kbd "M-y") '(lambda ()
                                 (interactive)
                                 (anything 'anything-c-source-kill-ring)))

  (global-set-key (kbd "C-x b") 'anything)
  (global-set-key (kbd "C-;") 'anything)
  (setq anything-sources
        (list anything-c-source-buffers+
              anything-c-source-ffap-guesser
              anything-c-source-files-in-current-dir+
              anything-c-source-file-name-history
              anything-c-source-locate
              anything-c-source-emacs-commands))

  ;; M-x
  (defvar anything-c-source-mx
    '((name . "M-x")
      (init . (lambda ()
                (with-current-buffer (anything-candidate-buffer 'local)
                  (loop for sym being the symbols
                        when (commandp sym)
                        do (insert (symbol-name sym) "\n")))))
      (type . command)
      (candidates-in-buffer))
    "Expand extended command with anything.el")
  (global-set-key (kbd "M-x")
                  (lambda () (interactive)
                    (anything '(anything-c-source-extended-command-history
                                anything-c-source-mx))))

  ;; jump anywhere
  (defvar anything-c-source-my-register-set
    '((name . "Set Register")
      (dummy)
      (action . point-to-register)))
  (defun anything-jump-anywhere ()
    (interactive)
    (anything (list anything-c-source-bookmarks
                    anything-c-source-register
                    anything-c-source-ctags
                    anything-c-source-bookmark-set
                    anything-c-source-my-register-set
                    )))
  (global-set-key (kbd "C-\\") 'anything-jump-anywhere)
  (global-set-key (kbd "C-=") 'anything-jump-anywhere)

)

;;; ------------------------------------------------------------------
;;; Dired
;;; ------------------------------------------------------------------

;; ls option
(setq dired-listing-switches "-alh")

;; open without create buffer
(put 'dired-find-alternate-file 'disabled nil)
(add-hook 'dired-load-hook
          '(lambda ()
             (define-key dired-mode-map (kbd "RET") 'dired-find-alternate-file)))

;; emphasize file that modified today
(defface my-face-f-2 '((t (:foreground "GreenYellow"))) nil)
(defvar my-face-f-2 'my-face-f-2)
(defun my-dired-today-search (arg)
  "Fontlock search function for dired."
  (search-forward-regexp
   (concat (format-time-string "%b %e" (current-time)) " [0-9]....") arg t))
(add-hook 'dired-mode-hook
          '(lambda ()
             (font-lock-add-keywords
              major-mode
              (list
               '(my-dired-today-search . my-face-f-2)))))

;; wdired.el
(lazyload (wdired-change-to-wdired-mode) "wdired" "http://www.emacswiki.org/cgi-bin/wiki/download/wdired.el")
(add-hook 'dired-load-hook
          '(lambda ()
             (define-key dired-mode-map (kbd "r") 'wdired-change-to-wdired-mode)))

;; sort menu by anything
(defvar dired-various-sort-type
  '(("S" . "size")
    ("X" . "extension")
    ("v" . "version")
    ("t" . "date")
    (""  . "name")))
(defun dired-various-sort-change (sort-type-alist &optional prior-pair)
  (when (eq major-mode 'dired-mode)
    (let* (case-fold-search
           get-next
           (options
            (mapconcat 'car sort-type-alist ""))
           (opt-desc-pair
            (or prior-pair
                (catch 'found
                  (dolist (pair sort-type-alist)
                    (when get-next
                      (throw 'found pair))
                    (setq get-next (string-match (car pair) dired-actual-switches)))
                  (car sort-type-alist)))))
      (setq dired-actual-switches
            (concat "-l" (dired-replace-in-string (concat "[l" options "-]")
                                                  ""
                                                  dired-actual-switches)
                    (car opt-desc-pair)))
      (setq mode-name
            (concat "Dired by " (cdr opt-desc-pair)))
      (force-mode-line-update)
      (revert-buffer))))
(defun dired-various-sort-change-or-edit (&optional arg)
  "Hehe"
  (interactive "P")
  (when dired-sort-inhibit
    (error "Cannot sort this dired buffer"))
  (if arg
      (dired-sort-other
       (read-string "ls switches (must contain -l): " dired-actual-switches))
    (dired-various-sort-change dired-various-sort-type)))
(defvar anything-c-source-dired-various-sort
  '((name . "Dired various sort type")
    (candidates . (lambda ()
                    (mapcar (lambda (x)
                              (cons (concat (cdr x) " (" (car x) ")") x))
                            dired-various-sort-type)))
    (action . (("Set sort type" . (lambda (candidate)
                                    (dired-various-sort-change dired-various-sort-type candidate)))))
    ))
(add-hook 'dired-mode-hook
          '(lambda ()
             (define-key dired-mode-map "s" 'dired-various-sort-change-or-edit)
             (define-key dired-mode-map "c"
               '(lambda ()
                  (interactive)
                  (cond ((featurep 'anything)
                         (anything '(anything-c-source-dired-various-sort)))
                        (t
                         (message "at first, install anything!")))))))

;; coloring
(add-hook 'dired-mode-hook
          '(lambda ()
             (defvar *original-dired-font-lock-keywords* (or dired-font-lock-keywords nil))
             (defun dired-highlight-by-extensions (highlight-list)
               "highlight-list accept list of (regexp [regexp] ... face)."
               (let ((lst nil))
                 (dolist (highlight highlight-list)
                   (push `(,(concat "\\.\\(" (regexp-opt (butlast highlight)) "\\)$")
                           (".+" (dired-move-to-filename)
                            nil (0 ,(car (last highlight)))))
                         lst))
                 (setq dired-font-lock-keywords
                       (append *original-dired-font-lock-keywords* lst))))
             (dired-highlight-by-extensions
              '(("txt" font-lock-variable-name-face)
                ("lisp" "el" "pl" "c" "h" "cc" "js" font-lock-constant-face)))
             ))

;;; ------------------------------------------------------------------
;;; Major Mode
;;; ------------------------------------------------------------------


;;; coffee-mode.el
(req coffee-mode nil
  (add-hook 'coffee-mode-hook '(lambda ()
                                 (when (featurep 'highlight-indentation)
                                   (highlight-indentation 2)
                                   (set-face-background 'highlight-indent-face "gray6"))))
  (setenv "PATH" (concat (expand-file-name "~/.nave/installed/0.4.12/bin")
                         ":"
                         (getenv "PATH")))
  (setq js2coffee-command "~/.nave/installed/0.4.12/bin/js2coffee"
        coffee-command "~/.nave/installed/0.4.12/bin/coffee"
        coffee-tab-width 2)
  (defun coffee-compile-replace-region (start end)
    "Compiles a region and displays the JS in another buffer."
    (interactive "r")
    ;;  fix ->
    (when (< (point) (region-end))
      (exchange-point-and-mark))
    ;; <- fix

    (let ((buffer (get-buffer coffee-compiled-buffer-name)))
      (when buffer
        (kill-buffer buffer)))

    (apply (apply-partially 'call-process-region start end coffee-command nil
                            (current-buffer)
                            nil)
           (append coffee-args-compile (list "-s" "-p")))
    (delete-region start end)
    )
  (defun coffee-js2coffee-replace-region (start end)
    "Replace JS to coffee in current buffer."
    (interactive "r")

    ;;  fix ->
    (when (< (point) (region-end))
      (exchange-point-and-mark))
    ;;  <- fix

    (let ((buffer (get-buffer coffee-compiled-buffer-name)))
      (when buffer
        (kill-buffer buffer)))

    (call-process-region start end
                         js2coffee-command nil
                         (current-buffer)
                         )
    (delete-region start end)
    )
  (defun coffee-exec-region (start end)
    "Compiles a region and displays the JS in another buffer."
    (interactive "r")
    (when (< (point) (region-end))
      (exchange-point-and-mark))
    (let ((buffer (get-buffer coffee-compiled-buffer-name)))
      (when buffer
        (kill-buffer buffer)))
    (apply (apply-partially 'call-process-region start end coffee-command nil
                            (current-buffer)
                            nil)
           (list "-s"))
    (comment-region end (max (point) (region-end)))
    (goto-char end)
    )
  (defun coffee-exec-buffer ()
    "Compiles a region and displays the JS in another buffer."
    (interactive)
    (goto-char (point-max))
    (coffee-exec-region (point-min) (point-max))
    )


  (define-key coffee-mode-map (kbd "C-c j") 'coffee-compile-replace-region)
  (define-key coffee-mode-map (kbd "C-c c") 'coffee-js2coffee-replace-region)
  (define-key coffee-mode-map (kbd "C-c e") 'coffee-exec-region)
  (define-key coffee-mode-map (kbd "C-c E") 'coffee-exec-buffer)

  )


;; ;;; html-helper-mode.el

;; (autoload 'html-helper-mode "html-helper-mode" "Yay HTML" t)
;; (setq auto-mode-alist (cons '("\\.html$" . html-helper-mode) auto-mode-alist))

;; (defgroup html-helper nil
;;   "Customizing html-helper-mode"
;;   :group 'languages
;;   :group 'hypermedia
;;   :group 'local)

;; (defgroup html-helper-faces nil
;;   "Customizing html-helper-mode custom faces"
;;   :group 'html-helper
;;   :group 'faces)

;; ;; Default distribution doesn't include visual-basic-mode
;; (defcustom html-helper-mode-uses-visual-basic nil
;;   "Non nil to require visual-basic-mode"
;;   :type 'boolean
;;   :initialize 'custom-initialize-default
;;   :group 'html-helper
;;   :require 'html-helper-mode)

;; (defcustom html-helper-mode-uses-JDE nil
;;   "No nil to use jde instead of java-mode"
;;   :type 'boolean
;;   :initialize 'custom-initialize-default
;;   :group 'html-helper
;;   :require 'html-helper-mode)

;; (defcustom html-helper-mode-uses-bold-italic nil
;;   "Non nil to use the bold-italic font (if your font supports it)"
;;   :type 'boolean
;;   :initialize 'custom-initialize-default
;;   :group 'html-helper
;;   :require 'html-helper-mode)

;; (defcustom html-helper-mode-uses-KG-style nil
;;   "Non nil to make Emacs consider PHP/ASP code blocks beginning in 
;; the first column"
;;   :type 'boolean
;;   :initialize 'custom-initialize-default
;;   :group 'html-helper
;;   :require 'html-helper-mode)

;; (defcustom html-helper-mode-global-JSP-not-ASP t
;;   "Non nil to make Emacs consider <% %> blocks as JSP (global default behaviour)"
;;   :type 'boolean
;;   :initialize 'custom-initialize-default
;;   :group 'html-helper
;;   :require 'html-helper-mode)

;; (progn
;;   (defvar html-tag-face
;;     (defface html-tag-face
;;       '((((class color)
;; 	  (background dark))
;; 	 (:foreground "deep red" :bold t))
;; 	(((class color)
;; 	  (background light))
;; 	 (:foreground "red" :bold t))
;; 	(t
;; 	 (:foreground "deep red" :bold t)))
;;       "Face to use for HTML tags."
;;       :group 'html-helper-faces))
;;   (defvar html-helper-bold-face 
;;     (defface html-helper-bold-face
;;       '((((class color)
;; 	  (background dark))
;; 	 (:foreground "wheat" :bold t))
;; 	(((class color)
;; 	  (background light))
;; 	 (:foreground "peru" :bold t))
;; 	(t
;; 	 (:foreground "peru" :bold t)))
;;       "Custom bold face."
;;       :group 'html-helper-faces))
;;   (defvar html-helper-italic-face 
;;     (defface html-helper-italic-face
;;       '((((class color)
;; 	  (background dark))
;; 	 (:foreground "spring green" :italic t))
;; 	(((class color)
;; 	  (background light))
;; 	 (:foreground "medium sea green" :italic t))
;; 	(t
;; 	 (:foreground "medium sea green" :italic t)))
;;       "Custom italic face."
;;       :group 'html-helper-faces))
;;   (cond (html-helper-mode-uses-bold-italic
;; 	 (defvar html-helper-bold-italic-face 
;; 	   (defface html-helper-bold-italic-face
;; 	     '((((class color)
;; 		 (background dark))
;; 		(:foreground "peachpuff" :bold t:italic t))
;; 	       (((class color)
;; 		 (background light))
;; 		(:foreground "orange" :bold t :italic t))
;; 	       (t
;; 		(:foreground "orange" :bold t :italic t)))
;; 	     "Custom bold italic face."
;; 	     :group 'html-helper-faces))))
;;   (defvar html-helper-underline-face 
;;     (defface html-helper-underline-face
;;       '((((class color)
;; 	  (background dark))
;; 	 (:foreground "cornsilk" :underline t))
;; 	(((class color)
;; 	  (background light))
;; 	 (:foreground "goldenrod" :underline t))
;; 	(t
;; 	 (:foreground "goldenrod" :underline t)))
;;       "Custom underline face."
;;       :group 'html-helper-faces)))


;;; markdown-mode.el
(autoload 'markdown-mode "markdown-mode.el"
  "Major mode for editing Markdown files" t)
(setq auto-mode-alist
      (cons '("\\.markdown" . markdown-mode) auto-mode-alist))

;;; lisp-mode.el
(add-hook 'emacs-lisp-mode-hook  ;; include lisp-interaction-mode-hook
          '(lambda ()
             (define-key emacs-lisp-mode-map (kbd "C-j") 'eval-print-last-sexp)
             (put 'req 'lisp-indent-function 'defun)
             (put 'lazyload 'lisp-indent-function 'defun)
             (when (featurep 'auto-complete)
               (make-local-variable 'ac-sources)
               (setq ac-sources (append ac-sources '(ac-source-symbols ac-source-filename))))
             ))

;; eldoc-extension.el
(lazyload (turn-on-eldoc-mode) "eldoc-extension" "http://www.emacswiki.org/cgi-bin/wiki/download/eldoc-extension.el"
  (setq eldoc-idle-delay 0.5)
  (setq eldoc-echo-area-use-multiline-p t))
(add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)


;; js2-mode.el
;; (lazyload (js2-mode) "js2" "http://js2-mode.googlecode.com/files/js2-20090723b.el")
(lazyload (js2-mode) "js2-mode" "https://github.com/mooz/js2-mode/raw/master/js2-mode.el"
  (setq js2-cleanup-whitespace nil
        js2-mirror-mode nil ; don't auto complete close paren
        ;;                    js2-bounce-indent-flag nil
        tab-width 4          ; tab
        js2-basic-offset 4   ; indent
        js2-strict-missing-semi-warning nil ; missing ; is not warning
        js2-mode-show-strict-warnings nil
        ;;      js2-auto-indent-flag nil    ; dont indent by { } ( ) [ ] : ; , *
        js2-rebind-eol-bol-keys nil ; dont rebind C-a C-e
        js2-highlight-level 3
        js2-use-ast-for-indentation-p t
        js2-indent-on-enter-key t ;;  retでインデントも
        js2-enter-indents-newline t
        )
  )
(add-to-list 'auto-mode-alist '("\\.js$" . js2-mode))

(add-hook 'js2-mode-hook
          '(lambda ()
             (define-key js2-mode-map (kbd "M-C-h") nil)
             (setq js2-cleanup-whitespace nil
                   js2-mirror-mode nil ; don't auto complete close paren
                   ;;                    js2-bounce-indent-flag nil
                   tab-width 4          ; tab
                   js2-basic-offset 4   ; indent
                   js2-strict-missing-semi-warning nil ; missing ; is not warning
                   js2-mode-show-strict-warnings nil
                   ;;      js2-auto-indent-flag nil    ; dont indent by { } ( ) [ ] : ; , *
                   js2-rebind-eol-bol-keys nil ; dont rebind C-a C-e
                   js2-highlight-level 3
                   )
             ))
;; ;;; espresso
;; (lazyload (espresso-mode) "espresso" "http://download.savannah.gnu.org/releases-noredirect/espresso/espresso.el")

;; (defun my-js2-indent-function ()
;;   (interactive)
;;   (save-restriction
;;     (widen)
;;     (let* ((inhibit-point-motion-hooks t)
;;            (parse-status (save-excursion (syntax-ppss (point-at-bol))))
;;            (offset (- (current-column) (current-indentation)))
;;            (indentation (espresso--proper-indentation parse-status))
;;            node)

;;       (save-excursion

;;         ;; I like to indent case and labels to half of the tab width
;;         (back-to-indentation)
;;         (if (looking-at "case\\s-")
;;             (setq indentation (+ indentation (/ espresso-indent-level 2))))

;;         ;; consecutive declarations in a var statement are nice if
;;         ;; properly aligned, i.e:
;;         ;;
;;         ;; var foo = "bar",
;;         ;;     bar = "foo";
;;         (setq node (js2-node-at-point))
;;         (when (and node
;;                    (= js2-NAME (js2-node-type node))
;;                    (= js2-VAR (js2-node-type (js2-node-parent node))))
;;           (setq indentation (+ 4 indentation))))

;;       (indent-line-to indentation)
;;       (when (> offset 0) (forward-char offset)))))

;; (defun my-indent-sexp ()
;;   (interactive)
;;   (save-restriction
;;     (save-excursion
;;       (widen)
;;       (let* ((inhibit-point-motion-hooks t)
;;              (parse-status (syntax-ppss (point)))
;;              (beg (nth 1 parse-status))
;;              (end-marker (make-marker))
;;              (end (progn (goto-char beg) (forward-list) (point)))
;;              (ovl (make-overlay beg end)))
;;         (set-marker end-marker end)
;;         (overlay-put ovl 'face 'highlight)
;;         (goto-char beg)
;;         (while (< (point) (marker-position end-marker))
;;           ;; don't reindent blank lines so we don't set the "buffer
;;           ;; modified" property for nothing
;;           (beginning-of-line)
;;           (unless (looking-at "\\s-*$")
;;             (indent-according-to-mode))
;;           (forward-line))
;;         (run-with-timer 0.5 nil '(lambda(ovl)
;;                                    (delete-overlay ovl)) ovl)))))

;; (defun my-js2-mode-hook ()
;;   (require 'espresso)
;;   (setq espresso-indent-level 4
;;         indent-tabs-mode nil
;;         c-basic-offset 4)
;;   (c-toggle-auto-state 0)
;;   (c-toggle-hungry-state 1)
;;   (set (make-local-variable 'indent-line-function) 'my-js2-indent-function)
;;   ; (define-key js2-mode-map [(meta control |)] 'cperl-lineup)
;;   (define-key js2-mode-map "\C-\M-\\"
;;     '(lambda()
;;        (interactive)
;;        (insert "/* -----[ ")
;;        (save-excursion
;;          (insert " ]----- */"))
;;        ))
;;   (define-key js2-mode-map "\C-m" 'newline-and-indent)
;;   ; (define-key js2-mode-map [(backspace)] 'c-electric-backspace)
;;   ; (define-key js2-mode-map [(control d)] 'c-electric-delete-forward)
;;   (define-key js2-mode-map "\C-\M-q" 'my-indent-sexp)
;;   (if (featurep 'js2-highlight-vars)
;;       (js2-highlight-vars-mode))
;;   (message "My JS2 hook"))

;; (add-hook 'js2-mode-hook 'my-js2-mode-hook)

;; ruby-mode.el
(lazyload (run-ruby inf-ruby-keys) "inf-ruby" nil)
(lazyload (ruby-mode) "ruby-mode" nil
  (add-hook 'ruby-mode-hook 'inf-ruby-keys))
(setq auto-mode-alist
      (append '(("\\.rb$" . ruby-mode)) auto-mode-alist))
(setq interpreter-mode-alist
      (append '(("ruby" . ruby-mode)) interpreter-mode-alist))

;;; php-mode.el
;;; http://sourceforge.net/projects/php-mode/
(lazyload (php-mode) "php-mode" nil
  (add-hook 'php-mode-user-hook
            '(lambda ()
               (setq tab-width 4)
               (setq indent-tabs-mode t)
               (setq c-basic-offset 4))))

;;; ------------------------------------------------------------------
;;; applications
;;; ------------------------------------------------------------------

;;; Dictionary.app + popup.el
(when (and darwin-p
           (featurep 'popup))
  (defvar dict-bin "~/bin/dict"
    "dict 実行ファイルのパス")

  (defun temp-cancel-read-only (function &optional jaspace-off)
    "eval temporarily cancel buffer-read-only
&optional t is turn of jaspace-mode"
    (let ((read-only-p nil)
          (jaspace-mode-p nil))
      (when jaspace-off
        (when jaspace-mode
          (jaspace-mode)
          (setq jaspace-mode-p t)))
      (when buffer-read-only
        (toggle-read-only)
        (setq read-only-p t))
      (eval function)
      (when read-only-p
        (toggle-read-only))
      (when jaspace-mode-p
        (jaspace-mode))))

  (defun ns-popup-dictionary ()
    "マウスカーソルの単語を Mac の辞書でひく"
    (interactive)
    (let ((word (substring-no-properties (thing-at-point 'word)))
          (old-buf (current-buffer))
          (dict-buf (get-buffer-create "*dictionary.app*"))
          (dict))
      (when (and mark-active transient-mark-mode)
        (setq word (buffer-substring-no-properties (region-beginning) (region-end))))
      (set-buffer dict-buf)
      (erase-buffer)
      (call-process dict-bin
                    nil "*dictionary.app*" t word
                    "Japanese-English" "Japanese" "Japanese Synonyms")
      (setq dict (buffer-string))
      (set-buffer old-buf)
      (when (not (eq (length dict) 0))
        (temp-cancel-read-only '(popup-tip dict :margin t :scroll-bar t) t))))

  (defvar dict-timer nil)
  (defvar dict-delay 1.0)
  (defun dict-timer ()
    (when (and (not (minibufferp))
               (and mark-active transient-mark-mode))
      (ns-popup-dictionary)))
  (setq dict-timer (run-with-idle-timer dict-delay dict-delay 'dict-timer))

  (define-key global-map (kbd "C-c e") 'ns-popup-dictionary))

;;; navi2ch
(when emacs-private-p
  (add-to-list 'load-path "~/.emacs.d/navi2ch")
  (autoload 'navi2ch "navi2ch" "Navigator for 2ch for Emacs" t))

;;; tails-history.el
;;; http://www.bookshelf.jp/elc/tails-history.el
(when (locate-library "tails-history")
  (load-library "tails-history"))

;;; ------------------------------------------------------------------
;;; Window
;;; ------------------------------------------------------------------

;;; popwin
(req popwin "https://github.com/m2ym/popwin-el/raw/master/popwin.el"
  (setq display-buffer-function 'popwin:display-buffer)
  (add-to-list 'popwin:special-display-config '("*Messages*"))
  (add-to-list 'popwin:special-display-config '("*Backtrace*" :noselect t))
  (add-to-list 'popwin:special-display-config '("*Warnings*" :noselect t))
  )



;;; e2wm.el
;; (auto-install-from-url "http://github.com/kiwanami/emacs-window-layout/raw/master/window-layout.el")
;; (auto-install-from-url "http://github.com/kiwanami/emacs-window-manager/raw/master/e2wm.el")
(lazyload (e2wm:start-management) "e2wm" "e2wm"
  (setq e2wm:c-code-recipe
        '(| (:left-size-ratio 0.2)
            (- (:upper-size-ratio 0.7)
               files history)
            (- (:upper-size-ratio 0.7)
               (| (:right-size-ratio 0.2)
                  main imenu)
               sub)))
  ;; ファイラ：C-hで上の階層へ
  (e2wm:add-keymap
   e2wm:def-plugin-files-mode-map
   '(("C-h" . e2wm:def-plugin-files-updir-command))
   e2wm:prefix-key)

  (e2wm:add-keymap
   e2wm:pst-minor-mode-keymap
   '(("<M-left>" . e2wm:dp-code) ; codeへ変更
     ("<M-right>" . e2wm:dp-two) ; twoへ変更
     ("<M-up>" . e2wm:dp-doc) ; docへ変更
     ("<M-down>" . e2wm:dp-dashboard) ; dashboardへ変更
     ("C-," . e2wm:pst-history-forward-command) ; 履歴を進む
     ("C-." . e2wm:pst-history-back-command) ; 履歴をもどる
     ("prefix L" . ielm)
     ("M-m" . e2wm:pst-window-select-main-command)
     ) e2wm:prefix-key)

  ;; ;; magit
  ;; (require 'e2wm-vcs)
  ;; (e2wm:add-keymap
  ;;  e2wm:pst-minor-mode-keymap
  ;;  '(("M-w" . e2wm:dp-magit))
  ;;  e2wm:prefix-key)
)

; (auto-install-from-url "https://github.com/kiwanami/emacs-window-manager/raw/master/e2wm-vcs.el")

(global-set-key (kbd "C-c e") 'e2wm:start-management)

;; windmove.el
;; shift + <cursor>
(windmove-default-keybindings)

;;; ------------------------------------------------------------------
;;; Edit
;;; ------------------------------------------------------------------

;;; sudo-ext.el
;;;
;;; M-x sudoedit
;;; (type password)
;;; (edit,save)
;;; C-x #
(req sudo-ext "http://www.emacswiki.org/emacs/download/sudo-ext.el")

;;; zencoding-mode.el --- Unfold CSS-selector-like expressions to markup
(req zencoding-mode "http://github.com/chrisdone/zencoding/raw/master/zencoding-mode.el"
  (add-hook 'sgml-mode-hook 'zencoding-mode) ;; Auto-start on any markup modes
  (add-hook 'html-mode-hook 'zencoding-mode))

;;; yasnippet.el
(when (require 'yasnippet nil t)
  (yas/initialize)
  (yas/load-directory (expand-file-name "~/.emacs.d/snippets"))
  (define-key yas/keymap (kbd "C-n") 'yas/next-field)
  (define-key yas/keymap (kbd "C-p") 'yas/prev-field)
; やりたいのはyas/skip-and-clear-or-backward-delete-charだった・・・
;   (define-key yas/keymap (kbd "C-h") 'yas/skip-and-clear-or-delete-char)

  ;; ;;; anything-c-yasnippet.el
  ;; ;;; http://svn.coderepos.org/share/lang/elisp/anything-c-yasnippet/anything-c-yasnippet.el
  ;; (require 'anything-c-yasnippet)
  ;; (setq anything-c-yas-space-match-any-greedy t)
  ;; (global-set-key (kbd "M-i") 'anything-c-yas-complete)
  ;; ; (add-to-list 'yas/extra-mode-hooks 'ruby-mode-hook)
  ;; (setq ac-sources
  ;;       '(ac-source-yasnippet ac-source-words-in-buffer))
  ;; ;; yasnippet for js2-mode
  ;; ; (add-to-list 'yas/extra-mode-hooks
  ;; ;              'js2-mode-hook)
  )

;;; auto-complete.el
;;; auto-complete-config.el
(req popup "http://github.com/m2ym/auto-complete/raw/master/popup.el"
(req auto-complete "https://github.com/m2ym/auto-complete/raw/master/auto-complete.el"
  (req auto-complete-config "https://github.com/m2ym/auto-complete/raw/master/auto-complete-config.el")
  (setq popup-use-optimized-column-computation nil)
  (setq ac-quick-help-delay 0.1)
  (global-auto-complete-mode t)
  (define-key ac-complete-mode-map (kbd "C-m") 'ac-complete)
  (define-key ac-complete-mode-map (kbd "C-n") 'ac-next)
  (define-key ac-complete-mode-map (kbd "C-p") 'ac-previous)
  (add-hook 'auto-complete-mode-hook
            (lambda ()
              (add-to-list 'ac-sources 'ac-source-yasnippet)
              ))
  ))

;;; rect-mark.el
;; (req rect-mark nil
;;   (define-key ctl-x-map "r\C-@" 'rm-set-mark)
;;   (define-key ctl-x-map [?r ?\C-\ ] 'rm-set-mark)
;;   (define-key ctl-x-map "r\C-x" 'rm-exchange-point-and-mark)
;;   (define-key ctl-x-map "r\C-w" 'rm-kill-region)
;;   (define-key ctl-x-map "r\M-w" 'rm-kill-ring-save)
;;   (define-key global-map [S-down-mouse-1] 'rm-mouse-drag-region)
;;   (defun set-normal-or-rectangel-mark-command ()
;;     (interactive)
;;     (cond ((not mark-active)
;;            (call-interactively 'set-mark-command))
;;           ((not rm-mark-active)
;;            (rm-activate-mark)
;;            (message "Rectangle mark set"))
;;           (t
;;            (rm-deactivate-mark)
;;            (set-mark-command nil))))
;;   (global-set-key (kbd "C-SPC") 'set-normal-or-rectangel-mark-command))

;;; mic-paren.el
(req mic-paren nil
  (paren-activate)
  (setq paren-sexp-mode t))

;;; linum
(when nt-p
  (global-linum-mode))

;;; jaspace.el
(req jaspace "http://homepage3.nifty.com/satomii/software/jaspace.el"
  (setq jaspace-highlight-tabs t))

;;; redo.el
(req redo "http://www.wonderworks.com/download/redo.el"
  (global-set-key (kbd "M-/") 'redo))

;;; hl-line.el
;;; hl-line+.el
(req hl-line+ "http://www.emacswiki.org/emacs/download/hl-line+.el"
  (hl-line-mode))

;;; dmacro.el
(lazyload (dmacro-exec) "dmacro" "http://pitecan.com/papers/JSSSTDmacro/dmacro.el")
(defconst *dmacro-key* (kbd "C-t") "繰返し指定キー")
(global-set-key *dmacro-key* 'dmacro-exec)

;;; thing-opt.el
(lazyload (upward-mark-thing) "thing-opt" "http://www.emacswiki.org/emacs/download/thing-opt.el"
  (setq upward-mark-thing-list
        '(;; special thing
          email
          url
          string
          ;; general thing
          symbol
          word
          ;; up-list
          (up-list . *)
          )))
(global-set-key (kbd "M-s") 'upward-mark-thing)


;;; active-region.el
(req active-region "http://github.com/snj14/active-region/raw/master/active-region.el"
(when (featurep 'anything)
  (defun active-region-anything (&optional arg)
    (interactive "*P")
    (cond ((consp arg) ;; C-u C-i
           (anything '(((name       . "Formatting")
                        (candidates . (indent-region
                                       align
                                       fill-region))
                        (action     . call-interactively))
                       ((name       . "Editing")
                        (candidates . (string-rectangle
                                       delete-rectangle
                                       iedit-mode
                                       narrow-to-region
                                       ))
                        (action     . call-interactively))
                       ((name       . "Converting")
                        (candidates . (upcase-region
                                       downcase-region
                                       capitalize-region
                                       base64-decode-region
                                       base64-encode-region
                                       tabify
                                       untabify))
                        (action     . call-interactively))
                       ((name       . "Converting (japanese)")
                        (candidates . (japanese-hankaku-region
                                       japanese-hiragana-region
                                       japanese-katakana-region
                                       japanese-zenkaku-region))
                        (action     . call-interactively))
                       )))
          ((active-region-multiple-line-p)
           (call-interactively 'indent-region)
           (message "indent region."))
          ))
  (define-key active-region-mode-map (kbd "C-i") 'active-region-anything)
  (define-key active-region-mode-map (kbd "M-r") 'active-region-replace)
  ;; window
  (defun other-window-or-split ()
    (interactive)
    (when (one-window-p)
      (split-window-horizontally))
    (other-window 1))
  (global-set-key (kbd "C-w") 'other-window-or-split)
  (global-set-key (kbd "M-w") 'delete-other-windows)
  ))

;;; smartchr.el
(req smartchr "http://github.com/imakado/emacs-smartchr/raw/master/smartchr.el"
  (global-set-key (kbd "=")  (smartchr '("=" "==" "===" " = " " == " " === ")))
  (global-set-key (kbd "'")  (smartchr '("'`!!''" "'")))
  (global-set-key (kbd "\"") (smartchr '("\"`!!'\"" "\"")))
  (global-set-key (kbd "{")  (smartchr '("{ `!!' }" "{")))
  (global-set-key (kbd "(")  (smartchr '("(`!!')" "(")))

  (define-key emacs-lisp-mode-map (kbd ";") (smartchr '("; " ";; " ";;; ")))
  (define-key lisp-interaction-mode-map (kbd ";") (smartchr '("; " ";; " ";;; "))))

;;; undo-tree
;;; orig http://www.dr-qubit.org/download.php?file=undo-tree/undo-tree.el
;;; mod  http://gist.github.com/raw/301447/a9d4a2202e695f950076fbec6fd6fc9407774b6a/undo-tree.el
(req undo-tree "http://gist.github.com/raw/301447/a9d4a2202e695f950076fbec6fd6fc9407774b6a/undo-tree.el"
  (global-undo-tree-mode))

;;; flush lines in occur buffer
(define-key occur-mode-map "F"
  (lambda (str) (interactive "sflush: ")
    (let ((buffer-read-only))
      (save-excursion
        (beginning-of-buffer)
        (forward-line 1)
        (beginning-of-line)
        (flush-lines str)))))
;;; keep lines in occur buffer
(define-key occur-mode-map "K"
  (lambda (str) (interactive "skeep: ")
    (let ((buffer-read-only))
      (save-excursion
        (beginning-of-buffer)
        (forward-line 1)
        (beginning-of-line)
        (keep-lines str)))))

;;; highlight yanked region
(when (or window-system (>= emacs-major-version 21))
  (defadvice yank (after ys:highlight-string activate)
    (let ((ol (make-overlay (mark t) (point))))
      (overlay-put ol 'face 'highlight)
      (sit-for 0.5)
      (delete-overlay ol)))
  (defadvice yank-pop (after ys:highlight-string activate)
    (when (eq last-command 'yank)
      (let ((ol (make-overlay (mark t) (point))))
        (overlay-put ol 'face 'highlight)
        (sit-for 0.5)
        (delete-overlay ol)))))

;;; time-stamp.el
(lazyload (time-stamp) "time-stamp" nil
  (setq time-stamp-active t)
  (setq time-stamp-start "last updated : ")
  (setq time-stamp-format "%04y-%02m-%02d")
  (setq time-stamp-end " \\|$"))
(add-hook 'before-save-hook 'time-stamp)

;;; highlight-indentation.el
(req highlight-indentation
  "https://raw.github.com/antonj/Highlight-Indentation-for-Emacs/master/highlight-indentation.el")

;;; ------------------------------------------------------------------
;;; File
;;; ------------------------------------------------------------------

;;; don't ask when open symlink file
(setq vc-follow-symlinks t)

;;; backup-directory
(setq make-backup-files t)
(setq backup-directory-alist
      (cons (cons "\\.*$" (expand-file-name "~/backup"))
            backup-directory-alist))

;;; magit.el
;;;
;;; install:
;;;  (ubuntu) synaptic -> magit
;;;
;;; usage:
;;;  M-x magit-status
;;;  n/p     : up/down
;;;  TAB     : expand
;;;  s       : stage
;;;  c       : write commit message
;;;  C-c C-c : commit
(req magit nil
  (global-set-key (kbd "C-c g") 'magit-status))

;;; uniquify.el
(req uniquify nil
     (setq uniquify-buffer-name-style 'post-forward-angle-brackets)
     )

;;; session.el
;;; http://sourceforge.net/projects/emacs-session/files/session/
(req session nil
     (setq session-save-file (expand-file-name "~/.emacs.d/.session"))
     (add-hook 'after-init-hook 'session-initialize))

;;; save *scratch*
(defun save-scratch-data ()
  (let ((str (progn
               (set-buffer (get-buffer "*scratch*"))
               (buffer-substring-no-properties
                (point-min) (point-max))))
        (file "~/.emacs.d/.scratch"))
    (if (get-file-buffer (expand-file-name file))
        (setq buf (get-file-buffer (expand-file-name file)))
      (setq buf (find-file-noselect file)))
    (set-buffer buf)
    (erase-buffer)
    (insert str)
    (save-buffer)))
(defadvice save-buffers-kill-emacs
  (before save-scratch-buffer activate)
  (save-scratch-data))
(defun read-scratch-data ()
  (let ((file "~/.emacs.d/.scratch"))
    (when (file-exists-p file)
      (set-buffer (get-buffer "*scratch*"))
      (erase-buffer)
      (insert-file-contents file))))
(add-hook 'kill-buffer-query-functions
          (function (lambda ()
                      (if (string= "*scratch*" (buffer-name))
                          (progn (message "*scratch* buffer is protected from kill-buffer.")
                                 nil)
                        t))))
(read-scratch-data)

;; reqpen-recent-closed-file
(defvar recent-closed-files nil)
(defun collect-recent-closed-files ()
  (when buffer-file-name
    (push buffer-file-name recent-closed-files)))
(add-hook 'kill-buffer-hook 'collect-recent-closed-files)
(defun reopen-recent-closed-file ()
  (interactive)
  (when recent-closed-files
    (let (path)
      (while (not (setq path (pop recent-closed-files))))
      (find-file path))))
(global-set-key (kbd "C-c C-t u") 'reopen-recent-closed-file)

;;; auto chmod +x
(when (or darwin-p
          linux-p)
  (add-hook 'after-save-hook
            'executable-make-buffer-file-executable-if-script-p))

;;; delete empty file
(defun delete-empty-file ()
  (when (and (buffer-file-name (current-buffer))
             (= (point-min) (point-max))
             (y-or-n-p "Delete file and kill buffer?"))
    (delete-file
     (buffer-file-name (current-buffer)))
    (kill-buffer (current-buffer))))
(add-hook 'after-save-hook 'delete-empty-file)

;;; ------------------------------------------------------------------
;;; minibuffer
;;; ------------------------------------------------------------------

;;; minibuf-isearch.el
(setq minibuf-isearch-fire-keys '("\C-p"))
(req minibuf-isearch "http://www.sodan.org/~knagano/emacs/minibuf-isearch/minibuf-isearch.el")

;;; cycle-mini.el
(req cycle-mini "http://joereiss.net/misc/cycle-mini.el")

;;; delete duplicated minibuffer history
;;; (require 'cl)
(defun minibuffer-delete-duplicate ()
  (set minibuffer-history-variable
       (delete-duplicates (symbol-value minibuffer-history-variable) :test 'equal)))
(add-hook 'minibuffer-setup-hook 'minibuffer-delete-duplicate)

;; use TAB for complete
(define-key read-expression-map (kbd "TAB") 'lisp-complete-symbol)

;;; minibuffer C-g memorize
(defadvice abort-recursive-edit (before minibuffer-save activate)
  (when (eq (selected-window) (active-minibuffer-window))
    (add-to-history minibuffer-history-variable (minibuffer-contents))))


;;; ------------------------------------------------------------------
;;; Search
;;; ------------------------------------------------------------------

;;; migemo.el
;;; linux : http://d.hatena.ne.jp/ser1zw/20100825/1282663086
(when linux-p
  (setq migemo-command "cmigemo")
  (setq migemo-options '("-q" "--emacs"))
  (setq migemo-dictionary "/usr/share/cmigemo/utf-8/migemo-dict")
  (setq migemo-user-dictionary nil)
  (setq migemo-regex-dictionary nil)
  (setq migemo-coding-system 'utf-8-unix)
  (load-library "migemo")
  (migemo-init))
(when darwin-p
    (setq migemo-command "/usr/local/bin/cmigemo")
    (setq migemo-options '("-q" "--emacs"))
    (setq migemo-dictionary "/usr/local/share/migemo/euc-jp/migemo-dict")
    (setq migemo-user-dictionary nil)
    (setq migemo-regex-dictionary nil)
    (setq migemo-use-pattern-alist nil)
    (setq migemo-use-frequent-pattern-alist nil)
    (setq migemo-pattern-alist-length 1024)
    (load-library "migemo")
    (migemo-init))

;;; color-moccur.el
(req color-moccur "http://www.bookshelf.jp/elc/color-moccur.el"
     (setq moccur-split-word t)
     (when (featurep 'migemo)
       (setq moccur-use-migemo t))
     )

;;; anything-c-moccur.el
(lazyload (anything-c-moccur-occur-by-moccur
           anything-c-moccur-dmoccur
           anything-c-moccur-isearch-forward
           anything-c-moccur-isearch-backward)
          "anything-c-moccur"  "http://svn.coderepos.org/share/lang/elisp/anything-c-moccur/trunk/anything-c-moccur.el"
    (global-set-key (kbd "M-o") 'anything-c-moccur-occur-by-moccur)
    (global-set-key (kbd "C-M-o") 'anything-c-moccur-dmoccur)
    (global-set-key (kbd "C-M-s") 'anything-c-moccur-isearch-forward)
    (global-set-key (kbd "C-M-r") 'anything-c-moccur-isearch-backward)
    (setq anything-c-moccur-anything-idle-delay 0
          anything-c-moccur-higligt-info-line-flag t
          anything-c-moccur-enable-auto-look-flag t
          anything-c-moccur-enable-initial-pattern t)
    (setq anything-c-source-occur-by-moccur
      `((name . "Occur by Moccur")
        (candidates . anything-c-moccur-occur-by-moccur-get-candidates)
        (action . (("Goto line" . anything-c-moccur-occur-by-moccur-goto-line)))
        (persistent-action . anything-c-moccur-occur-by-moccur-persistent-action)
        (init . anything-c-moccur-initialize)
        (cleanup . anything-c-moccur-clean-up)
        (match . (identity))
        (requires-pattern . 1)
        (delayed)
        (volatile)))
    )

;; isearch-occur
(defun isearch-occur ()
  "Invoke `occur' from within isearch."
  (interactive)
  (let ((case-fold-search isearch-case-fold-search))
    (occur
     (if isearch-regexp
         isearch-string (regexp-quote isearch-string)))))
(define-key isearch-mode-map (kbd "C-o") 'isearch-occur)

;; refe.el
;; (require 'refe nil t)

;; isearch.el
(setq isearch-lazy-highlight-initial-delay 0)

;;; ------------------------------------------------------------------
;;; test
;;; ------------------------------------------------------------------


(defun my-time-lag ()
  (let* ((now (current-time))
         (min (- (car now) (car my-time-zero)))
         (sec (- (car (cdr now)) (car (cdr my-time-zero))))
         (msec (/ (- (car (cdr (cdr now)))
                     (car (cdr (cdr my-time-zero))))
                     1000))
         (lag (+ (* 60000 min) (* 1000 sec) msec)))
    (message "'.emacs.el' loading time: %d msec." lag)))


(add-hook 'after-init-hook (lambda () (my-time-lag)) t)
(add-hook 'after-init-hook (lambda () (my-time-lag-print)) t)
