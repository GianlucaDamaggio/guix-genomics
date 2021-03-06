(define-module (freebayes)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cmake)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages base)
  #:use-module (gnu packages gcc)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages python)
  #:use-module (gnu packages wget)
  #:use-module (gnu packages bash)
  #:use-module (gnu packages compression))

(define-public freebayes
  (let ((version "v1.3.2")
        (commit "71a3e1c5eb8083a6f4205b65918323251162634a")
        (package-revision "1"))
    (package
     (name "freebayes")
     (version (string-append version "+" (string-take commit 7) "-" package-revision))
     (source (origin
              (method git-fetch)
              (uri (git-reference
                    (url "https://github.com/ekg/freebayes.git")
                    (commit commit)
                    (recursive? #t)))
              (file-name (git-file-name name version))
              (sha256
               (base32
                "1nhclcpaa0jz95kvd1dl2gvc14ilaq5qmbmhnd0qg6wmbgm8brdb"))))
     (build-system cmake-build-system)
     (arguments
      `(#:phases
        (modify-phases
         %standard-phases
         ;; Setting the SHELL environment variable is required by SeqLib's configure script
         (add-after 'unpack 'set-shell
                    (lambda _
                      (setenv "CONFIG_SHELL" (which "sh"))
                      #t))
         ;; This stashes our build version in the executable
         (add-after 'unpack 'set-version
                    (lambda _
                      (substitute* "src/version_release.txt" (("v1.0.0") ,version))
                      #t))
         (delete 'check))))
     (native-inputs
      `(("wget" ,wget)
        ("gcc" ,gcc-9)
        ("cmake" ,cmake)
        ("zlib" ,zlib)))
     (synopsis "freebayes haplotype-based genetic variant caller")
     (description
"freebayes is a Bayesian genetic variant detector designed to find small
polymorphisms, specifically SNPs (single-nucleotide polymorphisms), indels
(insertions and deletions), MNPs (multi-nucleotide polymorphisms), and complex
events (composite insertion and substitution events) smaller than the length of
a short-read sequencing alignment.")
     (home-page "https://github.com/ekg/freebayes")
     (license license:expat))))
