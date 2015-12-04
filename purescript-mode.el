;;; purescript-mode.el --- Major mode for editing Purescript -*- lexical-binding: t -*-

;; Copyright (C) 2014 Mario Rodas <marsam@users.noreply.github.com>

;; Author: Mario Rodas <marsam@users.noreply.github.com>
;; URL: https://github.com/emacs-pe/purescript-mode
;; Keywords: PureScript
;; Version: 0.1
;; Package-Requires: ((emacs "24"))

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Emacs major mode for PureScript.

;;; Code:
(eval-when-compile
  (require 'cl-lib)
  (defvar haskell-literate)           ; XXX: In order to use Haskell indentation
  (defvar compilation-error-regexp-alist)
  (defvar compilation-error-regexp-alist-alist))

(defgroup purescript nil
  "Settings for REPL interaction via `inferior-purescript-mode'"
  :prefix "purescript-"
  :group 'languages)

(defcustom purescript-project-root nil
  "Path to the PureScript project root."
  :type 'string
  :safe #'file-directory-p
  :group 'purescript)

(defcustom purescript-node-executable "node"
  "Executable of NodeJS."
  :type 'string
  :group 'purescript)

(defcustom purescript-project-root-files
  '(".psci"                             ; PureScript .psci file
    ".psci_modules"                     ; PureScript .psci_modules directory
    "bower.json"                        ; Bower project file
    "package.json"                      ; npm package file
    "gulpfile.js"                       ; Gulp build file
    "Gruntfile.js"                      ; Grunt project file
    "bower_components"                  ; Bower components directory
    )
  "List of files which be considered to locate the project root.
The topmost match has precedence."
  :type '(repeat string)
  :group 'purescript)

(defvar purescript-literate nil
  "Literate PureScript.

Because this mode stoles the `haskell-mode' font-fock and this
define the `haskell-literate' variable.  Purescript doesn't have
a literate mode yet, but this variable is necessary.")
(make-variable-buffer-local 'purescript-literate)
(put 'purescript-literate 'safe-local-variable 'symbolp)


;; XXX: Stolen from `haskell-mode'
(defvar purescript--char-syntax-symbols
  '((161 . 169) 172 (174 . 177) 180 (182 . 184) 191 215 247
    (706 . 709) (722 . 735) (741 . 747) 749 (751 . 767) 885
    894 (900 . 901) 903 1014 1154 (1370 . 1375) (1417 . 1418)
    (1421 . 1423) 1470 1472 1475 1478 (1523 . 1524) (1542 . 1551)
    1563 (1566 . 1567) (1642 . 1645) 1748 1758 1769 (1789 . 1790)
    (1792 . 1805) (2038 . 2041) (2096 . 2110) 2142 (2404 . 2405)
    2416 (2546 . 2547) (2554 . 2555) (2800 . 2801) 2928
    (3059 . 3066) 3199 3449 3572 3647 3663 (3674 . 3675)
    (3841 . 3863) (3866 . 3871) 3892 3894 3896 3973 (4030 . 4037)
    (4039 . 4044) (4046 . 4058) (4170 . 4175) (4254 . 4255)
    4347 (4960 . 4968) (5008 . 5017) 5120 (5741 . 5742)
    (5867 . 5869) (5941 . 5942) (6100 . 6102) (6104 . 6107)
    (6144 . 6154) 6464 (6468 . 6469) (6622 . 6623) (6624 . 6655)
    (6686 . 6687) (6816 . 6822) (6824 . 6829) (7002 . 7018)
    (7028 . 7036) (7164 . 7167) (7227 . 7231) (7294 . 7295)
    (7360 . 7367) 7379 8125 (8127 . 8129) (8141 . 8143)
    (8157 . 8159) (8173 . 8175) (8189 . 8190) (8208 . 8215)
    (8224 . 8231) (8240 . 8248) (8251 . 8260) (8263 . 8286)
    (8314 . 8316) (8330 . 8332) (8352 . 8381) (8448 . 8449)
    (8451 . 8454) (8456 . 8457) 8468 (8470 . 8472) (8478 . 8483)
    8485 8487 8489 8494 (8506 . 8507) (8512 . 8516) (8522 . 8525)
    8527 (8592 . 8703) (8704 . 8959) (8960 . 8967) (8972 . 9000)
    (9003 . 9210) (9216 . 9254) (9280 . 9290) (9372 . 9449)
    (9472 . 9599) (9600 . 9631) (9632 . 9727) (9728 . 9983)
    (9984 . 10087) (10132 . 10175) (10176 . 10180) (10183 . 10213)
    (10224 . 10239) (10240 . 10495) (10496 . 10623) (10624 . 10626)
    (10649 . 10711) (10716 . 10747) (10750 . 10751) (10752 . 11007)
    (11008 . 11123) (11126 . 11157) (11160 . 11193) (11197 . 11208)
    (11210 . 11217) (11493 . 11498) (11513 . 11516) (11518 . 11519)
    11632 (11776 . 11777) (11782 . 11784) 11787 (11790 . 11803)
    (11806 . 11807) (11818 . 11822) (11824 . 11841) (11904 . 11929)
    (11931 . 12019) (12032 . 12245) (12272 . 12283) (12289 . 12292)
    (12306 . 12307) 12316 12320 12336 (12342 . 12343)
    (12349 . 12351) (12443 . 12444) 12448 12539 (12688 . 12689)
    (12694 . 12703) (12736 . 12771) (12800 . 12830) (12842 . 12871)
    12880 (12896 . 12927) (12938 . 12976) (12992 . 13054)
    (13056 . 13311) (19904 . 19967) (42128 . 42182) (42238 . 42239)
    (42509 . 42511) 42611 42622 (42738 . 42743) (42752 . 42774)
    (42784 . 42785) (42889 . 42890) (43048 . 43051) (43062 . 43065)
    (43124 . 43127) (43214 . 43215) (43256 . 43258) (43310 . 43311)
    43359 (43457 . 43469) (43486 . 43487) (43612 . 43615)
    (43639 . 43641) (43742 . 43743) (43760 . 43761) 43867
    44011 64297 (64434 . 64449) (65020 . 65021) (65040 . 65046)
    65049 (65072 . 65076) (65093 . 65094) (65097 . 65103)
    (65104 . 65106) (65108 . 65112) (65119 . 65126) (65128 . 65131)
    (65281 . 65287) (65290 . 65295) (65306 . 65312) 65340
    (65342 . 65344) 65372 65374 65377 (65380 . 65381)
    (65504 . 65510) (65512 . 65518) (65532 . 65533) (65792 . 65794)
    (65847 . 65855) (65913 . 65929) 65932 (65936 . 65947)
    65952 (66000 . 66044) 66463 66512 66927 67671 (67703 . 67704)
    67871 67903 (68176 . 68184) 68223 68296 (68336 . 68342)
    (68409 . 68415) (68505 . 68508) (69703 . 69709) (69819 . 69820)
    (69822 . 69825) (69952 . 69955) (70004 . 70005) (70085 . 70088)
    70093 (70200 . 70205) 70854 (71105 . 71113) (71233 . 71235)
    (74864 . 74868) (92782 . 92783) 92917 (92983 . 92991)
    (92996 . 92997) 113820 113823 (118784 . 119029) (119040 . 119078)
    (119081 . 119140) (119146 . 119148) (119171 . 119172)
    (119180 . 119209) (119214 . 119261) (119296 . 119361)
    119365 (119552 . 119638) 120513 120539 120571 120597
    120629 120655 120687 120713 120745 120771 (126704 . 126705)
    (126976 . 127019) (127024 . 127123) (127136 . 127150)
    (127153 . 127167) (127169 . 127183) (127185 . 127221)
    (127248 . 127278) (127280 . 127339) (127344 . 127386)
    (127462 . 127487) (127488 . 127490) (127504 . 127546)
    (127552 . 127560) (127568 . 127569) (127744 . 127788)
    (127792 . 127869) (127872 . 127950) (127956 . 127991)
    (128000 . 128254) (128256 . 128330) (128336 . 128377)
    (128379 . 128419) (128421 . 128511) (128512 . 128578)
    (128581 . 128591) (128592 . 128639) (128640 . 128719)
    (128736 . 128748) (128752 . 128755) (128768 . 128883)
    (128896 . 128980) (129024 . 129035) (129040 . 129095)
    (129104 . 129113) (129120 . 129159) (129168 . 129197)))

(defvar purescript--char-syntax-identifiers
  '(170
    (178 . 179) 181 (185 . 186) (188 . 190) (192 . 214) (216 . 246)
    (248 . 255) (256 . 383) (384 . 591) (592 . 687) (880 . 883)
    (886 . 887) (891 . 893) 895 902 (904 . 906) 908 (910 . 929) (931 . 1013)
    (1015 . 1023) (1024 . 1153) (1162 . 1279) (1280 . 1327)
    (1329 . 1366) (1377 . 1415) (1488 . 1514) (1520 . 1522) (1568 . 1599)
    (1601 . 1610) (1632 . 1641) (1646 . 1647) (1649 . 1747) 1749
    (1774 . 1788) 1791 1808 (1810 . 1839) (1869 . 1871) (1872 . 1919)
    (1920 . 1957) 1969 (1984 . 2026) (2048 . 2069) (2112 . 2136) (2208 . 2226)
    (2308 . 2361) 2365 2384 (2392 . 2401) (2406 . 2415) (2418 . 2431)
    2432 (2437 . 2444) (2447 . 2448) (2451 . 2472) (2474 . 2480)
    2482 (2486 . 2489) 2493 2510 (2524 . 2525) (2527 . 2529) (2534 . 2545)
    (2548 . 2553) (2565 . 2570) (2575 . 2576) (2579 . 2600)
    (2602 . 2608) (2610 . 2611) (2613 . 2614) (2616 . 2617) (2649 . 2652)
    2654 (2662 . 2671) (2674 . 2676) (2693 . 2701) (2703 . 2705)
    (2707 . 2728) (2730 . 2736) (2738 . 2739) (2741 . 2745) 2749 2768
    (2784 . 2785) (2790 . 2799) (2821 . 2828) (2831 . 2832) (2835 . 2856)
    (2858 . 2864) (2866 . 2867) (2869 . 2873) 2877 (2908 . 2909)
    (2911 . 2913) (2918 . 2927) (2929 . 2935) 2947 (2949 . 2954) (2958 . 2960)
    (2962 . 2965) (2969 . 2970) 2972 (2974 . 2975) (2979 . 2980)
    (2984 . 2986) (2990 . 3001) 3024 (3046 . 3058) (3077 . 3084) (3086 . 3088)
    (3090 . 3112) (3114 . 3129) 3133 (3160 . 3161) (3168 . 3169)
    (3174 . 3183) (3192 . 3198) (3205 . 3212) (3214 . 3216) (3218 . 3240)
    (3242 . 3251) (3253 . 3257) 3261 3294 (3296 . 3297) (3302 . 3311)
    (3313 . 3314) (3333 . 3340) (3342 . 3344) (3346 . 3386) 3389
    3406 (3424 . 3425) (3430 . 3445) (3450 . 3455) (3461 . 3478) (3482 . 3505)
    (3507 . 3515) 3517 (3520 . 3526) (3558 . 3567) (3585 . 3632)
    (3634 . 3635) (3648 . 3653) (3664 . 3673) (3713 . 3714) 3716 (3719 . 3720)
    3722 3725 (3732 . 3735) (3737 . 3743) (3745 . 3747) 3749
    3751 (3754 . 3755) (3757 . 3760) (3762 . 3763) 3773 (3776 . 3780)
    (3792 . 3801) (3804 . 3807) 3840 (3872 . 3891) (3904 . 3911) (3913 . 3948)
    (3976 . 3980) (4096 . 4138) (4159 . 4169) (4176 . 4181)
    (4186 . 4189) 4193 (4197 . 4198) (4206 . 4208) (4213 . 4225) 4238
    (4240 . 4249) (4256 . 4293) 4295 4301 (4304 . 4346) (4349 . 4351)
    (4352 . 4607) (4608 . 4680) (4682 . 4685) (4688 . 4694) 4696 (4698 . 4701)
    (4704 . 4744) (4746 . 4749) (4752 . 4784) (4786 . 4789)
    (4792 . 4798) 4800 (4802 . 4805) (4808 . 4822) (4824 . 4880) (4882 . 4885)
    (4888 . 4954) (4969 . 4988) (4992 . 5007) (5024 . 5108)
    (5121 . 5740) (5743 . 5759) (5761 . 5786) (5792 . 5866) (5873 . 5880)
    (5888 . 5900) (5902 . 5905) (5920 . 5937) (5952 . 5969)
    (5984 . 5996) (5998 . 6000) (6016 . 6067) 6108 (6112 . 6121) (6128 . 6137)
    (6160 . 6169) (6176 . 6210) (6212 . 6263) (6272 . 6312) 6314
    (6320 . 6389) (6400 . 6430) (6470 . 6479) (6480 . 6509) (6512 . 6516)
    (6528 . 6571) (6593 . 6599) (6608 . 6618) (6656 . 6678)
    (6688 . 6740) (6784 . 6793) (6800 . 6809) (6917 . 6963) (6981 . 6987)
    (6992 . 7001) (7043 . 7072) (7086 . 7103) (7104 . 7141)
    (7168 . 7203) (7232 . 7241) (7245 . 7247) (7248 . 7287) (7401 . 7404)
    (7406 . 7409) (7413 . 7414) (7424 . 7467) (7531 . 7543)
    (7545 . 7551) (7552 . 7578) (7680 . 7935) (7936 . 7957) (7960 . 7965)
    (7968 . 8005) (8008 . 8013) (8016 . 8023) 8025 8027 8029
    (8031 . 8061) (8064 . 8116) (8118 . 8124) 8126 (8130 . 8132) (8134 . 8140)
    (8144 . 8147) (8150 . 8155) (8160 . 8172) (8178 . 8180)
    (8182 . 8188) 8304 (8308 . 8313) (8320 . 8329) 8450 8455 (8458 . 8467)
    8469 (8473 . 8477) 8484 8486 8488 (8490 . 8493) (8495 . 8505)
    (8508 . 8511) (8517 . 8521) 8526 (8528 . 8543) (8579 . 8580)
    8585 (9312 . 9371) (9450 . 9471) (10102 . 10131) (11264 . 11310)
    (11312 . 11358) (11360 . 11387) (11390 . 11391) (11392 . 11492)
    (11499 . 11502) (11506 . 11507) 11517 (11520 . 11557) 11559 11565
    (11568 . 11623) (11648 . 11670) (11680 . 11686) (11688 . 11694)
    (11696 . 11702) (11704 . 11710) (11712 . 11718) (11720 . 11726)
    (11728 . 11734) (11736 . 11742) 12294 12348 (12353 . 12438) 12447
    (12449 . 12538) 12543 (12549 . 12589) (12593 . 12686) (12690 . 12693)
    (12704 . 12730) (12784 . 12799) (12832 . 12841) (12872 . 12879)
    (12881 . 12895) (12928 . 12937) (12977 . 12991) (13312 . 19893)
    (19968 . 40908) (40960 . 40980) (40982 . 42124) (42192 . 42231)
    (42240 . 42507) (42512 . 42539) (42560 . 42606) (42624 . 42651)
    (42656 . 42725) (42786 . 42863) (42865 . 42887) (42891 . 42894)
    (42896 . 42925) (42928 . 42929) 42999 (43002 . 43007)
    (43008 . 43009) (43011 . 43013) (43015 . 43018) (43020 . 43042)
    (43056 . 43061) (43072 . 43123) (43138 . 43187) (43216 . 43225)
    (43250 . 43255) 43259 (43264 . 43301) (43312 . 43334) (43360 . 43388)
    (43396 . 43442) (43472 . 43481) (43488 . 43492) (43495 . 43518)
    (43520 . 43560) (43584 . 43586) (43588 . 43595) (43600 . 43609)
    (43616 . 43631) (43633 . 43638) 43642 (43646 . 43647)
    (43648 . 43695) 43697 (43701 . 43702) (43705 . 43709) 43712 43714
    (43739 . 43740) (43744 . 43754) 43762 (43777 . 43782) (43785 . 43790)
    (43793 . 43798) (43808 . 43814) (43816 . 43822) (43824 . 43866)
    (43876 . 43877) (43968 . 44002) (44016 . 44025) (44032 . 55203)
    (55216 . 55238) (55243 . 55291) (63744 . 64109) (64112 . 64217)
    (64256 . 64262) (64275 . 64279) 64285 (64287 . 64296)
    (64298 . 64310) (64312 . 64316) 64318 (64320 . 64321) (64323 . 64324)
    (64326 . 64335) (64336 . 64433) (64467 . 64829) (64848 . 64911)
    (64914 . 64967) (65008 . 65019) (65136 . 65140) (65142 . 65276)
    (65296 . 65305) (65313 . 65338) (65345 . 65370) (65382 . 65391)
    (65393 . 65437) (65440 . 65470) (65474 . 65479) (65482 . 65487)
    (65490 . 65495) (65498 . 65500) (65536 . 65547) (65549 . 65574)
    (65576 . 65594) (65596 . 65597) (65599 . 65613) (65616 . 65629)
    (65664 . 65786) (65799 . 65843) (65909 . 65912) (65930 . 65931)
    (66176 . 66204) (66208 . 66256) (66273 . 66299) (66304 . 66339)
    (66352 . 66368) (66370 . 66377) (66384 . 66421) (66432 . 66461)
    (66464 . 66499) (66504 . 66511) (66560 . 66639) (66640 . 66687)
    (66688 . 66717) (66720 . 66729) (66816 . 66855) (66864 . 66915)
    (67072 . 67382) (67392 . 67413) (67424 . 67431) (67584 . 67589)
    67592 (67594 . 67637) (67639 . 67640) 67644 67647 (67648 . 67669)
    (67672 . 67679) (67680 . 67702) (67705 . 67711) (67712 . 67742)
    (67751 . 67759) (67840 . 67867) (67872 . 67897) (67968 . 67999)
    (68000 . 68023) (68030 . 68031) 68096 (68112 . 68115)
    (68117 . 68119) (68121 . 68147) (68160 . 68167) (68192 . 68222)
    (68224 . 68255) (68288 . 68295) (68297 . 68324) (68331 . 68335)
    (68352 . 68405) (68416 . 68437) (68440 . 68447) (68448 . 68466)
    (68472 . 68479) (68480 . 68497) (68521 . 68527) (68608 . 68680)
    (69216 . 69246) (69635 . 69687) (69714 . 69743) (69763 . 69807)
    (69840 . 69864) (69872 . 69881) (69891 . 69926) (69942 . 69951)
    (69968 . 70002) 70006 (70019 . 70066) (70081 . 70084) (70096 . 70106)
    (70113 . 70132) (70144 . 70161) (70163 . 70187) (70320 . 70366)
    (70384 . 70393) (70405 . 70412) (70415 . 70416) (70419 . 70440)
    (70442 . 70448) (70450 . 70451) (70453 . 70457) 70461
    (70493 . 70497) (70784 . 70831) (70852 . 70853) 70855 (70864 . 70873)
    (71040 . 71086) (71168 . 71215) 71236 (71248 . 71257)
    (71296 . 71338) (71360 . 71369) (71840 . 71922) 71935 (72384 . 72440)
    (73728 . 74648) (77824 . 78894) (92160 . 92728) (92736 . 92766)
    (92768 . 92777) (92880 . 92909) (92928 . 92975) (93008 . 93017)
    (93019 . 93025) (93027 . 93047) (93053 . 93071) (93952 . 94020)
    94032 (110592 . 110593) (113664 . 113770) (113776 . 113788)
    (113792 . 113800) (113808 . 113817) (119648 . 119665) (119808 . 119892)
    (119894 . 119964) (119966 . 119967) 119970 (119973 . 119974)
    (119977 . 119980) (119982 . 119993) 119995 (119997 . 120003)
    (120005 . 120069) (120071 . 120074) (120077 . 120084)
    (120086 . 120092) (120094 . 120121) (120123 . 120126) (120128 . 120132)
    120134 (120138 . 120144) (120146 . 120485) (120488 . 120512)
    (120514 . 120538) (120540 . 120570) (120572 . 120596)
    (120598 . 120628) (120630 . 120654) (120656 . 120686) (120688 . 120712)
    (120714 . 120744) (120746 . 120770) (120772 . 120779)
    (120782 . 120831) (124928 . 125124) (125127 . 125135) (126464 . 126467)
    (126469 . 126495) (126497 . 126498) 126500 126503 (126505 . 126514)
    (126516 . 126519) 126521 126523 126530 126535 126537
    126539 (126541 . 126543) (126545 . 126546) 126548 126551 126553
    126555 126557 126559 (126561 . 126562) 126564 (126567 . 126570)
    (126572 . 126578) (126580 . 126583) (126585 . 126588) 126590 (126592 . 126601)
    (126603 . 126619) (126625 . 126627) (126629 . 126633)
    (126635 . 126651) (127232 . 127244) (131072 . 173782) (173824 . 177972)
    (177984 . 178205) (194560 . 195101)))

;; Syntax table.
(defvar purescript-mode-syntax-table
  (let ((table (make-syntax-table)))
    (modify-syntax-entry ?\  " " table)
    (modify-syntax-entry ?\t " " table)
    (modify-syntax-entry ?\" "\"" table)
    (modify-syntax-entry ?\' "_" table)
    (modify-syntax-entry ?_  "w" table)
    (modify-syntax-entry ?\( "()" table)
    (modify-syntax-entry ?\) ")(" table)
    (modify-syntax-entry ?\[  "(]" table)
    (modify-syntax-entry ?\]  ")[" table)

    (modify-syntax-entry ?\{  "(}1nb" table)
    (modify-syntax-entry ?\}  "){4nb" table)
    (modify-syntax-entry ?-  ". 123" table)
    (modify-syntax-entry ?\n ">" table)

    (modify-syntax-entry ?\` "$`" table)

    (mapc (lambda (x)
            (modify-syntax-entry x "." table))
          "!#$%&*+./:<=>?@^|~,;\\")

    ;; PureScript symbol characters are treated as punctuation because
    ;; they are not able to form identifiers with word constituent 'w'
    ;; class characters.
    (dolist (charcodes purescript--char-syntax-symbols)
      (modify-syntax-entry charcodes "." table))
    ;; ... and for identifier characters
    (dolist (charcodes purescript--char-syntax-identifiers)
      (modify-syntax-entry charcodes "w" table))

    table)
  "Syntax table used in PureScript mode.")

(defun purescript-ident-at-point ()
  "Return the identifier under point, or nil if none found.
May return a qualified name."
  (let ((reg (purescript-ident-pos-at-point)))
    (when reg
      (buffer-substring-no-properties (car reg) (cdr reg)))))

(defun purescript-spanable-pos-at-point ()
  "Like `purescript-ident-pos-at-point', but includes any surrounding backticks."
  (save-excursion
    (let ((pos (purescript-ident-pos-at-point)))
      (when pos
        (cl-destructuring-bind (start . end) pos
          (if (and (eq ?` (char-before start))
                   (eq ?` (char-after end)))
              (cons (- start 1) (+ end 1))
            (cons start end)))))))

(defun purescript-ident-pos-at-point ()
  "Return the span of the identifier under point, or nil if none found.
May return a qualified name."
  (save-excursion
    ;; Skip whitespace if we're on it.  That way, if we're at "map ", we'll
    ;; see the word "map".
    (if (and (not (eobp))
             (eq ?  (char-syntax (char-after))))
        (skip-chars-backward " \t"))

    (let ((case-fold-search nil))
      (cl-multiple-value-bind (start end)
          (list
           (progn (skip-syntax-backward "w_") (point))
           (progn (skip-syntax-forward "w_") (point)))
        ;; If we're looking at a module ID that qualifies further IDs, add
        ;; those IDs.
        (goto-char start)
        (while (and (looking-at "[[:upper:]]") (eq (char-after end) ?.)
                    ;; It's a module ID that qualifies further IDs.
                    (goto-char (1+ end))
                    (save-excursion
                      (when (not (zerop (skip-syntax-forward
                                         (if (looking-at "\\s_") "_" "w'"))))
                        (setq end (point))))))
        ;; If we're looking at an ID that's itself qualified by previous
        ;; module IDs, add those too.
        (goto-char start)
        (if (eq (char-after) ?.) (forward-char 1)) ;Special case for "."
        (while (and (eq (char-before) ?.)
                    (progn (forward-char -1)
                           (not (zerop (skip-syntax-backward "w'"))))
                    (skip-syntax-forward "'")
                    (looking-at "[[:upper:]]"))
          (setq start (point)))
        ;; This is it.
        (unless (= start end)
          (cons start end))))))

(defun purescript-fill-paragraph (justify)
  (save-excursion
    ;; Fill paragraph should only work in comments.
    ;; The -- comments are handled properly by default
    ;; The {- -} comments need some extra love.
    (let* ((syntax-values (syntax-ppss))
           (comment-num (nth 4 syntax-values)))
      (cond
       ((eq t comment-num)
        ;; standard fill works wonders inside a non-nested comment
        (fill-comment-paragraph justify))

       ((integerp comment-num)
        ;; we are in a nested comment. lets narrow to comment content
        ;; and use plain paragraph fill for that
        (let* ((comment-start-point (nth 8 syntax-values))
               (comment-end-point
                (save-excursion
                  (goto-char comment-start-point)
                  (forward-sexp)
                  ;; Find end of any comment even if forward-sexp
                  ;; fails to find the right braces.
                  (backward-char 3)
                  (re-search-forward "[ \t]?-}" nil t)
                  (match-beginning 0)))
               (fill-start (+ 2 comment-start-point))
               (fill-end comment-end-point)
               (fill-paragraph-handle-comment nil))
          (save-restriction
            (narrow-to-region fill-start fill-end)
            (fill-paragraph justify)
            ;; If no filling happens, whatever called us should not
            ;; continue with standard text filling, so return t
            t)))
       ((eolp)
        ;; do nothing outside of a comment
        t)
       (t
        ;; go to end of line and try again
        (end-of-line)
        (purescript-fill-paragraph justify))))))



;;;###autoload
(defvar purescript-mode-compilation-regex-alist-alist
  `((psc ,(rx line-start (* space) (? "Error ") "at " (group (minimal-match (one-or-more not-newline)))
              " line " (group (+ num)) ", column " (group (+ num)) " - line " (group (+ num)) ", column " (group (+ num)) (? ":"))
         1 (2 . 3) (4 . 5) (6 . nil)))
  "Alist for PureScript errors.  See: `compilation-error-regexp-alist'.")

;;;###autoload
(defvar purescript-mode-compilation-regex-alist (mapcar 'cdr purescript-mode-compilation-regex-alist-alist)
  "PureScript `compilation-error-regexp-alist'.")

;;;###autoload
(eval-after-load 'compile
  '(dolist (alist purescript-mode-compilation-regex-alist-alist)
     (add-to-list 'compilation-error-regexp-alist (car alist))
     (add-to-list 'compilation-error-regexp-alist-alist alist)))

;;;###autoload
(define-derived-mode purescript-mode prog-mode "PureScript"
  "Major mode for PureScript.

\\<purescript-mode-map>"
  :group 'purescript
  :syntax-table purescript-mode-syntax-table
  (set (make-local-variable 'paragraph-start)
       (concat " *{-\\| *-- |\\|" page-delimiter))
  (set (make-local-variable 'paragraph-separate)
       (concat " *$\\| *-- |\\| *\\({-\\|-}\\) *$\\|" page-delimiter))
  (set (make-local-variable 'fill-paragraph-function) 'purescript-fill-paragraph)
  (set (make-local-variable 'adaptive-fill-mode) nil)
  (set (make-local-variable 'comment-start) "-- ")
  (set (make-local-variable 'comment-padding) 0)
  (set (make-local-variable 'comment-start-skip) "[-{]-[ \t]*")
  (set (make-local-variable 'comment-end) "")
  (set (make-local-variable 'comment-end-skip) "[ \t]*\\(-}\\|\\s>\\)")
  (set (make-local-variable 'parse-sexp-ignore-comments) nil)
  (set (make-local-variable 'font-lock-defaults)
       '(purescript-font-lock-choose-keywords
         nil nil ((?\' . "w") (?_  . "w")) nil
         (font-lock-syntactic-keywords
          . purescript-font-lock-choose-syntactic-keywords)
         (font-lock-syntactic-face-function
          . purescript-syntactic-face-function)
         ;; Get help from font-lock-syntactic-keywords.
         (parse-sexp-lookup-properties . t)))
  (set (make-local-variable 'indent-tabs-mode) nil)
  (set (make-local-variable 'tab-width) 8)
  (when (boundp 'electric-indent-inhibit)
    (setq electric-indent-inhibit t))
  (setq haskell-literate nil
        purescript-literate nil))


(defun purescript-locate-base-directory (&optional directory throw-error)
  "Locate a project root DIRECTORY for a purescript project.

If THROW-ERROR is non-nil throws an signal error if project root
couldn't be found."
  (let ((directory (or directory default-directory)))
    (cl-loop for file in purescript-project-root-files
             for project-root-dir = (locate-dominating-file directory file)
             when project-root-dir
             return project-root-dir
             finally (and throw-error (error "Project root not found")))))

(defun purescript-project-root (&optional directory)
  "Return a PuresScript project root from DIRECTORY."
  (or purescript-project-root (purescript-locate-base-directory directory)))

(defun purescript-project-root-or-error (&optional directory)
  "Return a PuresScript project root from DIRECTORY."
  (or (purescript-project-root directory) (error "Project root not found")))

(defvar purescript-module-history nil)

;; XXX: For debugging purposes, don't rely much on this.
;;;###autoload
(defun purescript-locate-compiled-file (module)
  "Find the compiled file of a PureScript MODULE."
  (interactive (list (read-string "Module: " (purescript-find-module-name) 'purescript-module-history)))
  (let* ((root-dir (purescript-project-root-or-error))
         (node-path (expand-file-name (format ".psci_modules/node_modules") root-dir))
         (process-environment (append (list (format "NODE_PATH=%s" node-path))
                                      process-environment)))
    (find-file-other-window (car (process-lines purescript-node-executable "-e" (format "process.stdout.write(require.resolve('%s'))" module))))))

(defun purescript-find-module-name ()
  "Find PureScript module name from the current buffer."
  (save-excursion
    (goto-char (point-min))
    (and (re-search-forward"^module[ \t]+\\(\\(?:\\sw\\|[.]\\)+\\)" nil t)
         (match-string-no-properties 1))))


;;; Pursuit
;;;###autoload
(defcustom purescript-pursuit-url "http://pursuit.purescript.org/search?q=%s"
  "Default value for pursuit website."
  :group 'purescript
  :type '(choice
          (const :tag "purescript.org" "http://pursuit.purescript.org/search?q=%s")
          string))

;;;###autoload
(defalias 'pursuit #'purescript-pursuit)

;;;###autoload
(defun purescript-pursuit (query)
  "Do a pursuit search for QUERY."
  (interactive (let ((def (purescript-ident-at-point)))
                 (if (and def (symbolp def)) (setq def (symbol-name def)))
                 (list (read-string (if def
                                        (format "pursuit query (default %s): " def)
                                      "pursuit query: ")
                                    nil nil def))))
  (browse-url (format purescript-pursuit-url (url-hexify-string query))))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.purs\\'" . purescript-mode))

(provide 'purescript-mode)

;;; purescript-mode.el ends here
