#!/usr/bin/env bash

function welcome(){
	base64 "misc/logo$(( ( RANDOM %  $(ls misc/ | grep logo | wc -l)  ) ))" --decode
	echo "** Android Kernel Research **"
}


function download_sdk(){
        echo "[*] Downloading SDK..."
        # https://dl.google.com/android/repository/repository-11.xml

        wget https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip --append-output $1
        unzip -qq sdk-tools-linux-4333796.zip
        rm sdk-tools-linux-4333796.zip
	
	tools/bin/sdkmanager --update
	tools/bin/sdkmanager "platforms;android-25"
	tools/bin/sdkmanager "build-tools;25.0.2"
 	tools/bin/sdkmanager "extras;google;m2repository"
 	tools/bin/sdkmanager "extras;android;m2repository"
	tools/bin/sdkmanager "system-images;android-16;default;armeabi-v7a"	
	tools/bin/sdkmanager "emulator"
	tools/bin/sdkmanager "platform-tools"
	tools/bin/sdkmanager --licenses

}

function download_prebuild(){
	echo "[*] Downloading Prebuild..."
	git clone https://android.googlesource.com/platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.6
}

function configure(){
	echo "[*] Configure..."
	git clone https://android.googlesource.com/kernel/goldfish
	git clone https://github.com/Fuzion24/AndroidKernelExploitationPlayground.git && \
	mv AndroidKernelExploitationPlayground kernel_exploit_challenges && \
	cd goldfish && git checkout -t origin/android-goldfish-3.4 && \
	git am --signoff < ../kernel_exploit_challenges/kernel_build/debug_symbols_and_challenges.patch && \
	cd .. && ln -s $(pwd)/kernel_exploit_challenges/ goldfish/drivers/vulnerabilities
}

function build_kernel(){
	echo "[*] Build Kernel..."
	export ARCH=arm SUBARCH=arm CROSS_COMPILE=arm-linux-androideabi- &&\
	export PATH=$(pwd)/arm-linux-androideabi-4.6/bin/:$PATH && \
	cd goldfish && make goldfish_armv7_defconfig && make -j8
	cd ..
}

function build_emulator(){
	echo "[*] Build Emulator..."
	tools/android create avd --force -k "system-images;android-16;default;armeabi-v7a" -n kernel_challenges
}

function download(){
	download_sdk $1
	download_prebuild
}

function fix_stuff(){
	ln -s /usr/lib/x86_64-linux-gnu/libpython2.7.so \
/usr/lib/x86_64-linux-gnu/libpython2.6.so.1.0
}

function main(){	
	welcome
	log_file=".setup_log_$(date +%Y-%m-%d_%H:%M)"
	download $log_file
	configure
	fix_stuff
	build_kernel
	build_emulator
}

main
echo "[*] Done!"
