#Note
The video directory will be used to download local copies from archive.org. Since the Raspberry Pi often runs on tiny disks it is recommended to mount some mass storage somplace and symlink the video directory to it. You can try:

ls -s ~/mnt/usb ~/apps/prelingerpane/public/video

note that once you do that you will not be able to see the curent contentos of this directory (including this file) until you unlink it.
