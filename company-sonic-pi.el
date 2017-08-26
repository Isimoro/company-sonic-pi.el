;;; company-sonic-pi.el --- Auto Completion For Sonic Pi

;; Copyright (C) 2011 Free Software Foundation, Inc.

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

;;; Installation:

;;; Usage:

;;; Code:

(require 'company)

(defvar company-sonic-pi-dict "~/.spacemacs.d/layers/sonic-pi/dic"
  "File with sonic pi words")

(defvar company-sonic-pi-dict-list (read-lines company-sonic-pi-dict-file)
  "List the expressions found in 'company-sonic-pi-dict'")

(defun read-lines (filePath)
  "Return a list of lines of a file at filePath."
  (with-temp-buffer
    (insert-file-contents filePath)
    (split-string (buffer-string) "\n" t)))

(defun company-sonic-pi-prefix (regexp expression)
  "Returns the prefix for matching given REGEXP, EXPRESSION is a Number,
specifying the matched paranthesized expression."
  (let ((prefix (and (eq major-mode 'sonic-pi-mode)
                     (company-grab regexp expression))))
    (if prefix (cons prefix t) nil)))

(defun company-sonic-pi-dict-candidates (prefix)
  "Completes PREFIX with expressions in a 'company-sonic-pi-dict'"
  (all-completions prefix company-sonic-pi-dict-list))

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

;;;###autoload
(defun company-sonic-pi-backend (command &optional arg &rest ignored)
  "company sonic pi backend. Does currently not recognise prefixes with a
leading colon"
  (interactive (list 'interactive))
  (case command
    (interactive (company-begin-backend 'company-sonic-pi-backend))
    (prefix (and (eq major-mode 'sonic-pi-mode)
                 ;; TODO Use company-sonic-prefix instead of grab-symbol
                 (company-grab-symbol)))
    (candidates (company-sonic-pi-dict-candidates arg))))

;;;###autoload
(defun company-sonic-pi-sample-backend (command &optional arg &rest ignored)
  "company Backend for sonic pi samples"
  (interactive (list 'interactive))
  (case command
    (interactive (company-begin-backend 'company-sonic-pi-sample-backend))
    (prefix (company-sonic-pi-prefix "sample[[:space:]]+:\\([a-z_]*\\)" 1))
    (candidates (company-sonic-pi-sample-candidate arg))))

(provide 'company-sonic-pi)

;;; company-sonic-pi.el ends here
