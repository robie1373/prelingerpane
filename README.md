# Prelingerpane
## what
A ruby gem intended to be run on Raspberry Pi. Attach to a vintage tv for maximum ambiance. 
## why
Because I was raised in a bubble of the '50's which emerged during the late 70's. 
## Installation
#### Set up your pi
I'm using the [Occidentalis](http://learn.adafruit.com/adafruit-raspberry-pi-educational-linux-distro/) distro from Adafruit. It comes with some extras that I wanted and they are the poop. Start [here](http://learn.adafruit.com/adafruit-raspberry-pi-lesson-1-preparing-and-sd-card-for-your-raspberry-pi) if you are just beginning.
Continue with one of the many fine intro to raspberry pi tuts out there until you have a basic, configured rpi.
#### Install Ruby
Since I like ruby, that's what Prelingerpane is written in. You'll need to install it in order to use PP. A good guide is available from [elinux.org](http://elinux.org/RPi_Ruby_on_Rails)
_Note: When you get to the part where you infall RVM you can omit rails. You don't that that and it will save you time and space._

`curl -L get.rvm.io | bash -s stable`
_That will do the job. Carry on._

#### Set up some local directories
Pi's are often run on fairly small disks, and don't have a lot of room to spare. Since one of the features of PP is the ability to store some video locally for what ever reason your little heart desires we'll set up a place to mount a USB stick. If you don't use a USB stick, you'll still need the directory to store downloaded files.

`mkdir -p ~/mnt/usb`

to mount the USB stick at boot time
`sudo echo /dev/disk2 /home/pi/mnt/usb #TODO mount options`
I also like to keep my home directories neat so I created a `~/apps` directory and installed PP there. That's nice in case you decide to run another app on your pi later.

`mkdir ~/apps/`

#### Install Prelingerpane
finally time for the magic. Prelingerpane is a Sinatra app which I recommend cloning out of the git repo. This will give you the latest version.

`cd ~/apps`

`git clone https://github.com/robie1373/prelingerpane.git`

`cd prelingerpane && bundle install`

#### Run Prelingerpane
Right now I'm just manually running the ruby app from SSH. I would like to provide a nice init script so it can be started, stopped and bounced from the web interface but I haven't gotten to that yet.  You know you'll see it here when I do.
In the meantime just log into you pi and 
`ruby ~/apps/prelingerpane/app.rb &`
As a side effect, you'll see some logging type info (_as well as some crufty instrumentation I may have forgotten to clean up_) scroll by.

## Usage

Point your browser at http://raspberrypi:4567
Optionally enter a search term and click *Search*
You can play the results on the device you are using to control the PP by clicking the link in *Search Results*
You can play one of the results on the PP by selecting the radio button next to it in the *Play* section and clicking *Play One*
You can save any of the videos to the ~/mnt/usb/prelingerpane directory by checking the box next to them in the *Save* section and clicking *Download*
You can play videos from the local storage by clicking the *local storage* link in the header.
Manage doesn't do anything yet.
About tells you usefulish things.

## Known issues
Too many to count at this point, but here are a few.
* Doesn't play .ogv which sucks since many of Prelinger's videos are Oggs.
* No feedback on downloads
* Very little error handling
* No proper logging
* Not secure in any way. Seriously. Do not put this on an untrusted network. Also, the Internet is definitely not trusted.
Please let me know if you find any bugs/things-I-just-didn't-finish by opening an issue [here](https://github.com/robie1373/prelingerpane/issues)
## Thanks
Again too many to count. In particular I leaned on 
* [Adafruit](http://www.adafruit.com/) Please buy their things. They're awesome.
* [elinux.org](http://elinux.org/) They seem to have just the right amount of detail on Linux-y things. 
* [omxplayer](https://github.com/huceke/omxplayer) for the Pi. It makes the pictures go. That's a big deal.
* Countless thousands of web pages and forum contributors who have given me the answer I needed over the years.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
6. Write more tests than I have
