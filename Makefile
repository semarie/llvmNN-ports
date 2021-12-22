# $OpenBSD$

# for lang/rust and lang/zig
ONLY_FOR_ARCHS =	aarch64 amd64 i386 sparc64

DPB_PROPERTIES =	parallel

COMMENT =	modular, fast C/C++/ObjC compiler, static analyzer and tools

PKGNAME =	llvm13-${LLVM_VERSION}pl${LLVM_DATE}

# version: https://github.com/mordak/llvm-project/blob/openbsd-release/13.x/llvm/CMakeLists.txt
# commit:  https://github.com/mordak/llvm-project/commits/openbsd-release/13.x
LLVM_VERSION =	13.0.1
LLVM_COMMIT =	ab436c534f2714fa94f6cf0704a8b58c1339ab3c
LLVM_DATE =	20211219

SUBST_VARS +=	LLVM_VERSION

CATEGORIES =	devel

SHARED_LIBS =	LLVM-13		0.0 \
		LTO		0.0 \
		Remarks		0.0 \
		clang-cpp	0.0 \
		clang		0.0

HOMEPAGE =	https://www.llvm.org/

MAINTAINER =	Sebastien Marie <semarie@online.fr>

# Apache License v2.0 with LLVM Exceptions
PERMIT_PACKAGE =	Yes

WANTLIB +=	${COMPILER_LIBCXX} c edit execinfo m z

MASTER_SITES =	https://github.com/mordak/llvm-project/archive/

DISTFILES =	llvm-project-${LLVM_VERSION}-${LLVM_COMMIT:C/(........).*/\1/}${EXTRACT_SUFX}{${LLVM_COMMIT}${EXTRACT_SUFX}}

WRKDIST =	${WRKDIR}/llvm-project-${LLVM_COMMIT}
WRKSRC =	${WRKDIR}/llvm-project-${LLVM_COMMIT}/llvm

# C++11
COMPILER =	base-clang ports-gcc

MODULES =	devel/cmake \
		lang/python

.include <bsd.port.arch.mk>

.if !${PROPERTIES:Mclang}
RUN_DEPENDS +=	lang/gcc/${MODGCC4_VERSION},-c++
.endif

MODPY_ADJ_FILES +=	\
	../clang/tools/clang-format/git-clang-format \
	../clang/tools/scan-build-py/bin/analyze-build \
	../clang/tools/scan-build-py/bin/intercept-build \
	../clang/tools/scan-build-py/bin/scan-build \
	../clang/tools/scan-build-py/libexec/analyze-c++ \
	../clang/tools/scan-build-py/libexec/analyze-cc \
	../clang/tools/scan-build-py/libexec/intercept-cc \
	../clang/tools/scan-build-py/libexec/intercept-c++ \
	../clang/tools/scan-view/bin/scan-view \
	../clang/utils/hmaptool/hmaptool

CONFIGURE_STYLE =	cmake
CONFIGURE_ARGS +=	\
	-DCMAKE_INSTALL_PREFIX="${LOCALBASE}/llvm13" \
	-DCMAKE_PREFIX_PATH="${LOCALBASE}/llvm13" \
	-DCLANG_INCLUDE_DOCS=OFF \
	-DCLANG_PLUGIN_SUPPORT=OFF \
	-DLLVM_ENABLE_BACKTRACES=OFF \
	-DLLVM_ENABLE_BINDINGS=OFF \
	-DLLVM_ENABLE_FFI=OFF \
	-DLLVM_ENABLE_LIBXML2=OFF \
	-DLLVM_ENABLE_OCAMLDOC=OFF \
	-DLLVM_ENABLE_PLUGINS=OFF \
	-DLLVM_ENABLE_PROJECTS="clang;lld" \
	-DLLVM_ENABLE_TERMINFO=OFF \
	-DLLVM_ENABLE_RTTI=OFF \
	-DLLVM_ENABLE_Z3_SOLVER=OFF \
	-DLLVM_INCLUDE_TESTS=OFF \
	-DLLVM_INCLUDE_GO_TESTS=OFF \
	-DLLVM_INCLUDE_EXAMPLES=OFF \
	-DLLVM_INCLUDE_BENCHMARKS=OFF \
	-DLLVM_BUILD_LLVM_DYLIB=ON \
	-DLLVM_LINK_LLVM_DYLIB=ON \
	-DGO_EXECUTABLE=GO_EXECUTABLE-NOTFOUND \

# Disable some protections in the compiler to regain performance.
CXXFLAGS-aarch64 =	-fno-ret-protector
CXXFLAGS-amd64 =	-fno-ret-protector -mno-retpoline
CXXFLAGS-i386 =		-fno-ret-protector -mno-retpoline
CXXFLAGS-mips64 =	-fno-ret-protector -fomit-frame-pointer
CXXFLAGS-mips64el =	-fno-ret-protector -fomit-frame-pointer
CXXFLAGS-powerpc =	-fno-ret-protector
CXXFLAGS +=	${CXXFLAGS-${MACHINE_ARCH}}

NO_TEST =	Yes

post-install:
	rm 	${PREFIX}/llvm13/lib/libLLVM.so \
		${PREFIX}/llvm13/lib/libLLVM-${LLVM_VERSION}.so
	${MODPY_BIN} ${MODPY_LIBDIR}/compileall.py \
		${PREFIX}/llvm13/lib/libear \
		${PREFIX}/llvm13/lib/libscanbuild \
		${PREFIX}/llvm13/share/clang \
		${PREFIX}/llvm13/share/opt-viewer \
		${PREFIX}/llvm13/share/scan-view

.include <bsd.port.mk>
