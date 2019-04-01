FROM ubuntu:16.04

RUN \
	apt-get update && \
	apt-get install -y \
		git \
		cmake \
		libxml2-dev \
		libfltk1.3-dev \
		g++ \
		libjpeg-dev \
		libcpptest-dev \
		libglm-dev \
		libeigen3-dev \
		libcminpack-dev \
		libglew-dev \
		swig \
		unzip

ARG OPENVSP_VER
ENV OPENVSP_VER ${OPENVSP_VER:-3.15.0}
ENV OPENVSP_PATH_BASE /opt/OpenVSP/

RUN \
	echo "build OpenVSP version ${OPENVSP_VER}"; \
	mkdir -p ${OPENVSP_PATH_BASE}; \
	cd ${OPENVSP_PATH_BASE}; \
	mkdir repo build buildlibs; \
	git clone https://github.com/OpenVSP/OpenVSP.git repo && \
	cd repo && \
	git checkout OpenVSP_${OPENVSP_VER}
	
RUN \
	cd ${OPENVSP_PATH_BASE}/buildlibs && \
	cmake -DCMAKE_BUILD_TYPE=Release -DVSP_USE_SYSTEM_FLTK=false -DVSP_USE_SYSTEM_CPPTEST=false -DVSP_USE_SYSTEM_LIBXML2=true -DVSP_USE_SYSTEM_EIGEN=false -DVSP_USE_SYSTEM_FLTK=false -DVSP_USE_SYSTEM_GLM=true -DVSP_USE_SYSTEM_GLEW=true -DVSP_USE_SYSTEM_CMINPACK=true ../repo/Libraries -DCMAKE_BUILD_TYPE=Release && \
	make -j8 && \
	cp ${OPENVSP_PATH_BASE}/buildlibs/FLTK-prefix/bin/fluid ${OPENVSP_PATH_BASE}/repo/src/vsp_aero/viewer/fluid && \
	cp ${OPENVSP_PATH_BASE}/buildlibs/FLTK-prefix/bin/fluid ${OPENVSP_PATH_BASE}/repo/src/fltk_screens/fluid

RUN \
	cd ${OPENVSP_PATH_BASE}/build && \
	cmake ../repo/src/ -DVSP_LIBRARY_PATH=/opt/OpenVSP/buildlibs -DCMAKE_BUILD_TYPE=Release && \
	make -j8

RUN \
	cd ${OPENVSP_PATH_BASE}/build && \
	make package && \
	cd ${OPENVSP_PATH_BASE} && \
	unzip ${OPENVSP_PATH_BASE}/build/OpenVSP-${OPENVSP_VER}-Linux.zip

VOLUME ${OPENVSP_PATH_BASE}
WORKDIR ${OPENVSP_PATH_BASE}
