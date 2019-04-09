echo "[*] Starting Android Emulator"
emulator/emulator -show-kernel -kernel goldfish/arch/arm/boot/zImage -avd kernel_challenges -no-boot-anim -no-skin -no-audio -no-window -qemu -monitor unix:/tmp/qemuSocket,server,nowait -gdb tcp::9999

