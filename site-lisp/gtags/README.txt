��gtags.l�ɂ���
  ����gtags.l �́AGNU GLOBAL�p��gtags.el��
  bulb��xyzzy�p�ɈڐA�������̂ł��B


���Y�L�����emacs lisp �ڐA�L�b�g���g�킹�Ē����܂����B���肪�Ƃ��������܂��B
  http://members.at.infoseek.co.jp/osuneko/xyzzy/xyzzy.html


�����C�Z���X
  GPL(GNU General Public License)�ł�(���Ԃ�)�B


���C���X�g�[��
��NetInstaller�̏ꍇ
 ���̃}�j���A���C���X�g�[�����΂��āA���L�����ݒ��ݒ肵�Ă��������B

���}�j���A���C���X�g�[���̏ꍇ
  ��1
    gtags�t�H���_��site-lisp�t�H���_�ɃR�s�[���ĉ������B

  ��2
    ���t�@�C���̑���GNU GLOBAL�̃C���X�g�[�����K�v�ł��B
    �{�Ƃ��� http://www.gnu.org/software/global/
    win32�ł��_�E�����[�h���āA
    PATH���ʂ��Ă���t�H���_�ɉ𓀂��Ă��������B

    Emacs�d�q���I���񂪎Q�l�ɂȂ�܂��B
    http://www.bookshelf.jp/soft/meadow_42.html#SEC621

  ��3
    ���L�̏����ݒ�̑O�ɉ��L��t���Ă��������B
(export 'ed::gtags-mode "ed")
(autoload 'ed::gtags-mode "gtags/gtags" t)
(require "gtags/gtags-menu")



�������ݒ�
  .xyzzy �� siteinit.l �ɉ��L��ǉ����ĉ������B
  ���L�ݒ�(�I���W�i��)�̂܂܂ł��ƁAC-t �Ƃ� M-r�Ȃǂ̃L�[�o�C���h���ׂ�Ă��܂��̂ŁA
  ���D�݂̃L�[�o�C���h�ɕύX���ĉ������B

;;; Emacs Lisp �ڐA�L�b�g
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
              ;(gtags-make-complete-list);���Ή�
              ))
(add-hook '*c++-mode-hook*
          #'(lambda ()
              (gtags-mode 1)))
(add-hook '*php-mode-hook*
          #'(lambda ()
              (gtags-mode 1)))
(in-package "user")


���g����
��1 GTAGS�̐������@
  �����j���[
  �c�[�����j���[�ɂ���uGTAGS�t�@�C���̍쐬�v��I���B
  �^�O���쐬�������\�[�X�f�B���N�g���Ɉړ�����
  OK�������Ɛ�������܂��B

  1.��������f�B���N�g����GTAGS�t�@�C�����Ȃ��ꍇ�͐V�K�ɐ����B
  2.���ł�GTAGS�t�@�C�������݂��Ă���ꍇ��Incremental�ɃA�b�v�f�[�g
  �܂�C�������\�[�X����TAG�t�@�C�����X�V���܂��B

  ���R�}���h���C�����琶������ꍇ
  > cd source    ;�^�O����肽���\�[�X�f�B���N�g���Ɉړ�
  > gtags -v     ;GTAGS�𐶐�

  xyzzy����́AC-x & �� �t�@�C���[��F3 ����
  > gtags
  �ƃ^�C�v���邱�ƂŐ������邱�Ƃ��ł��܂��B

  �X�V�����t�@�C�������𔽉f���������ꍇ�́A
  > global -u

��2 �W�����v�̃L�[�o�C���h
  M-t �֐��̒�`���փW�����v
  M-r �֐����Q�ƌ��̈ꗗ��\���BRET �ŎQ�ƌ��փW�����v
  M-s �ϐ��̒�`���ƎQ�ƌ��̈ꗗ��\���BRET �ŊY���ӏ��փW�����v
  M-e gtags-select-mode�o�b�t�@���o�R�����ɁA�_�C���N�g�W�����v
  C-t �O�̃o�b�t�@�֖߂�
  M-j �Q�ƌ��̈ꗗ��\��(grep���g�p)
  M-c �J�[�\�������ɂ���w�b�_�t�@�C���ɃW�����v(C/C++�̂�)
  M-n ���̌��ֈړ�
  M-p �O�̌��ֈړ�
  M-. .c <--> .h�t�@�C�����g�O������(C/C++�̂�)


���X�V����
  2007/12/27
  �Eemacs.l�ˑ��̉���(NANRI�����)
  �Egtags-find-tag-by-event(�T�|�[�g�O)��������C��
    �o�C�g�R���p�C�����ʂ�悤�ɏC���B
  �EREADME.txt�̓Y�t

  2007/07/21
  �Egtags-menu.l�̃o�O�C���B
    �f�B���N�g���w��̎d�����~�X���Ă����B
  �Eniup�L�O

  2006/11/14
  �Egtags-ext.l��gtags-toggle-source��ǉ��B
    elisp��toggle-source.el���Q�l�ɂ��܂����B

  2006/11/01
  �Egtags-menu.l�̈����ԈႢ���C��(OHKUBO����w�E orz)

  2006/08/26
  �Egtags-menu.l���C���B�X�V����������I���ł���悤�ɒǉ��B

  2006/08/13
  �Egtags-menu.l����typo���C��(�L�����Z���̕s�)�B

  2006/08/10
  �E�g�����Ȃǂ�ǉ��B
  �Egtags-ext.l�̍쐬�B
  �E(in-package "editor")�ɑΉ��B

  2006/08/07
  �ENetInstaller�Ή�

  2005/09/05
  �E��肩���̃t�@�C����require���Ă����̂��폜�B
  �Egtags-select-mode���̃L�[�o�C���h���I���W�i���ɍ��킹���B

  2005/08/04
  �E�Ƃ肠�������Ń����[�X�B


�����₢���킹
  bulb <ttomise at gmail dot com>

