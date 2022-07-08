class Htslib131 < Formula
  desc "C library for high-throughput sequencing data formats"
  homepage "http://www.htslib.org/"
  # tag "bioinformatics"
  # tag origin homebrew-science
  # tag derived

  url "https://github.com/samtools/htslib/archive/1.3.1.tar.gz"
  version "1.3.1"
  sha256 "3bbd04f9a0c4c301abd5d19a81920894ac2ee5e86e8aa977e8c2035e01d93ea7"

  keg_only 'Old version set to 1.3.1'

  depends_on "curl"
  depends_on 'libtool'
  depends_on 'autoconf'
  depends_on "zlib" unless OS.mac?
  patch :DATA

  def install
    inreplace 'Makefile', 'CFLAGS   = -g -Wall -O2', 'CFLAGS   = -g -Wall -O2 -Wno-unused -Wno-unused-result -fPIC'
    system 'autoreconf --verbose --install'
    system "./configure", "--enable-plugins", "--enable-libcurl", "--prefix=#{prefix}"
    system "make", "install"
    pkgshare.install "test"
    htsbash = (etc+'htslib.bash')
    File.delete(htsbash) if File.exists?(htsbash)
    (htsbash).write <<~EOF
      HTSLIB_DIR=#{prefix}
    EOF
  end

  test do
    sam = pkgshare/"test/ce#1.sam"
    assert_match "SAM", shell_output("htsfile #{sam}")
    system "bgzip -c #{sam} > sam.gz"
    assert File.exist?("sam.gz")
    system "tabix", "-p", "sam", "sam.gz"
    assert File.exist?("sam.gz.tbi")
  end
end
__END__
diff --git a/configure.ac b/configure.ac
index 6f658a2..78ac1aa 100644
--- a/configure.ac
+++ b/configure.ac
@@ -22,6 +22,9 @@
 # FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 # DEALINGS IN THE SOFTWARE.

+m4_ifndef([m4_esyscmd_s], [m4_define([m4_chomp_all], [m4_format([[%.*s]], m4_bregexp(m4_translit([[$1]], [/], [/ ]), [/*$]), [$1])])])
+m4_ifndef([m4_esyscmd_s], [m4_define([m4_esyscmd_s], [m4_chomp_all(m4_esyscmd([$1]))])])
+
 dnl Process this file with autoconf to produce a configure script
 AC_INIT([HTSlib], m4_esyscmd_s([make print-version]),
         [samtools-help@lists.sourceforge.net], [], [http://www.htslib.org/])
