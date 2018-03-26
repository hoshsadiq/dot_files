# todo this is untested.

if cat /etc/*release | grep ^NAME | grep -iq ubuntu; then
    source ./linux-gnu/ubuntu-preapps.sh
    source ./linux-gnu/ubuntu-apps.sh
    source ./linux-gnu/ubuntu-settings.sh

    # todo move this to a separate file
    gobin="$(dirname $(dpkg -L "golang-$GOLANG_VERSION-go | grep 'bin/go$'))"

    $gobin/go get -u github.com/jtyr/gbt/cmd/gbt
    $gobin/go get -u github.com/suntong/cascadia

    echo "export PATH=$gobin:\$PATH" >> ~/.zshrc_local

    # Section "InputClass"
    #         Identifier "libinput touchpad catchall"
    #         MatchIsTouchpad "on"
    #         MatchDevicePath "/dev/input/event*"
    #         Driver "libinput"
    #         Option "Tapping" "off"
    #         Option "TappingButtonMap" "lrm"
    #         Option "CoastingSpeed" "35"
    #         Option "CoastingFriction" "40"
    #         Option "FingerLow" "30"
    #         Option "FingerHigh" "50"
    # EndSection
else
  echo "Platform not supported"
  exit 1;
fi
