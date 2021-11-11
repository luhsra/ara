from ubuntu:focal
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/Berlin

# z3 bringt kein pkg-config mit, aber cmake von svf benötigt es.
COPY z3.pc /usr/share/pkgconfig/z3.pc
RUN apt update\
	&& apt-get install -y pkg-config clang-10 llvm-10-dev llvm-11-dev clang-11 llvm-12-dev clang-12 python3 python3-pip tmux build-essential ninja-build git binutils-arm-none-eabi libnewlib-arm-none-eabi libstdc++-arm-none-eabi-newlib bash-completion gdb-multiarch z3
RUN echo "deb http://downloads.skewed.de/apt focal main" > /etc/apt/sources.list.d/graph_tool.list\
	&& apt-key adv --keyserver keys.openpgp.org --recv-key 612DEFB798507F25\
	&& apt-get update \
	&& apt-get install -y python3-graph-tool
RUN apt-get install -y libboost-graph-dev cython3 python3-pydot python3-pydotplus\
	libsparsehash-dev gperf cmake g++-multilib\
	libboost-python-dev

# dependencies for qemu-stm32
RUN apt-get install -y libnss3 libglib2.0-dev libpixman-1-dev libfdt-dev libtinfo5

# tool for stm32 nucleo board flashing
RUN apt-get install -y stlink-tools

# get newer versions since the currently available ones dont fulfill or requirements
# we need 0.53.0 or >= 0.55.0
RUN pip3 install meson>=0.54.2 cython

RUN apt-get install -y python3-serial python3-future python3-matplotlib
RUN pip3 install -U versuchung matplotlib


CMD ["bash"]
