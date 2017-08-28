;;; company-sonic-pi.el --- Auto Completion For Sonic Pi

;; Copyright (C) 2017 Lukas Wöll

;; Author: Lukas Wöll <lukas.woell@protonmail.com>
;; Version: 1.0
;; Package-Requires: ((company "0.8.0"))

;; Keywords: SonicPi

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Work in Progress.
;; Be warned: I learn emacs lisp as well as writing company backends in the
;; process of writing these, so don't expect this to be optimized.

;; Heavily inspired by the completion backends provided by company-auctex
;; https://github.com/alexeyr/company-auctex/

;; #####################
;; What currently Works:
;; #####################

;; Completion of expressions provided in a file (not if expression starts with
;; colon)

;; Completion of samples stored in sonic-pis default directory after the
;; "sample" command.

;; ####################
;; What doesn't work:
;; ####################

;; Completion of anything starting with anything but sample names starting with
;; a colon.

;; Context sensitive completion other than sample names after "sample" command

;; completion of user defined function and variables. Not sure if that will ever
;; work as long as the server has no documented api for this. I haven't really
;; looked into the inner workings of the sonic-pi gui to figure out how it
;; handles this - if you have feel free to tell me.

;; ###################
;; What you can do
;; ###################

;; Whatever you want but if you want to help me, tell me what I'm doing wrong
;; and why what I'm doing is wrong.
;; (pls no "lel emacs, use the gui – shithead")

;;; Installation:

;; The completion Backends need to be added to company modes backend list and
;; variables "company-sonic-pi-dict" and "sonic-pi-path" need to be set, the
;; latter is the same variable sonic-pi.el uses.
;; TODO: More specific Instructions.

;;; Usage:

;;; Code:

(require 'company)

(defun read-lines (filePath)
  "Return a list of lines of a file at filePath."
  (with-temp-buffer
    (insert-file-contents filePath)
    (split-string (buffer-string) "\n" t)))

;; TODO make a proper list of sonic-pi expressions so it doesn't need to read
;; this file all the time.
(defvar company-sonic-pi-dict "~/.spacemacs.d/layers/sonic-pi/dic"
  "File with sonic pi words")

(defvar company-sonic-pi-dict-list (read-lines company-sonic-pi-dict)
  "List the expressions found in 'company-sonic-pi-dict'")

(defun company-sonic-pi-prefix (regexp expression)
  "Returns the prefix for matching given REGEXP, EXPRESSION is a Number,
specifying the matched paranthesized expression."
  (let ((prefix (and (eq major-mode 'sonic-pi-mode)
                     (company-grab regexp expression))))
    (if prefix (cons prefix t) nil)))

(defun company-sonic-pi-dict-candidates (prefix)
  "Completes PREFIX with expressions in a 'company-sonic-pi-dict'"
  (all-completions prefix company-sonic-pi-dict-list))

;; TODO condense the candidate functions synth, fx and sample into one thing.
;; Probably will be a general file-name completion makro that takes the path and
;; the regexp for clipping the names as arguments.

(defun company-sonic-pi-sample-candidate (prefix)
  "Completes PREFIX with the names of files in Sonic-Pis default sample
directory. Cuts the file extension and dotfiles."
  (let (datei-liste '())
    (dolist
        (sample
         (file-name-all-completions prefix
                                    (format "%setc/samples" sonic-pi-path))
         datei-liste)
      (add-to-list 'datei-liste
                   (replace-regexp-in-string "\\.[a-z]+"
                                             ""
                                             (format "%s" sample))))))

(defun company-sonic-pi-synth-candidate (prefix)
  "Completes PREFIX with the names of files in Sonic-Pis default synthdef
directory. Cuts the file extension and prefix."
  (let (datei-liste '())
    (dolist
        (synth
         (file-name-all-completions prefix
                                    (format "%setc/synthdefs/compiled"
                                            sonic-pi-path))
         datei-liste)
      (add-to-list 'datei-liste
                   (replace-regexp-in-string "sonic-pi-\\|.scsyndef"
                                             ""
                                             (format "%s" synth))))))

(defun company-sonic-pi-fx-candidate (prefix)
  "Completes PREFIX with the names of files in Sonic-Pis default synthdef
directory that start with the pattern \"sonic-pi-fx_\". Cuts the file extension
and prefix."
  (let (datei-liste '())
    (dolist
        (fx
         (file-name-all-completions prefix
                                    (format "%setc/synthdefs/compiled"
                                            sonic-pi-path))
         datei-liste)
      (add-to-list 'datei-liste
                   (replace-regexp-in-string "sonic-pi-fx_\\|.scsyndef"
                                             ""
                                             (format "%s" fx))))))

;;;###autoload
(defun company-sonic-pi-backend (command &optional arg &rest ignored)
  "company sonic pi backend. Does currently not recognise prefixes with a
leading colon"
  (interactive (list 'interactive))
  (case command
    (interactive (company-begin-backend 'company-sonic-pi-backend))
    (prefix (company-sonic-pi-prefix "[[:space:]]+\\([a-zA-Z_:-]+\\)" 1))
    (candidates (company-sonic-pi-dict-candidates arg))))

;;;###autoload
(defun company-sonic-pi-sample-backend (command &optional arg &rest ignored)
  "company Backend for sonic pi samples"
  (interactive (list 'interactive))
  (case command
    (interactive (company-begin-backend 'company-sonic-pi-sample-backend))
    (prefix (company-sonic-pi-prefix "sample[[:space:]]+:\\([a-z_]*\\)" 1))
    (candidates (company-sonic-pi-sample-candidate arg))))

;;;###autoload
(defun company-sonic-pi-synth-backend (command &optional arg &rest ignored)
  "company Backend for sonic-pi synths"
  (interactive (list 'interactive))
  (case command
    (interactive (company-begin-backend 'company-sonic-pi))
    (prefix (company-sonic-pi-prefix "synth[[:space:]]+:\\([a-z_]*\\)" 1))
    (candidate (company-sonic-pi-synth-candidate arg))))

;;;###autoload
(defun company-sonic-pi-fx-backend (command &optional arg &rest ignored)
  "company Backend for sonic-pi synths"
  (interactive (list 'interactive))
  (case command
    (interactive (company-begin-backend 'company-sonic-pi))
    (prefix (company-sonic-pi-prefix "with_fx[[:space:]]+:\\([a-z_]*\\)" 1))
    (candidate (company-sonic-pi-synth-candidate arg))))

;; Next thing TODO: proper autocompletion for parameters. Probably using
;; yasnippet before I'll try to replicate the way the Sonic-Pi-IDE does it.

(provide 'company-sonic-pi)

;;; company-sonic-pi.el ends here
