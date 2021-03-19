''
  #!/usr/bin/env dash

  screenshot() {
    case "$1" in
      area)
        # shellcheck disable=SC2046
        shotgun $(hacksaw -c "$( (rg primary | awk '{print $2}' | sed 's/^#//') < ~/.Xresources )" -f '-i %i -g %g') - | xclip -t 'image/png' -selection clipboard
        ;;
      full)
        shotgun ~/Media/Pictures/screenshots/"$(date '+%B-%d-%Y-%I:%M-%p')".png
        ;;
      wind)
        shotgun -i "$(xdo id)" - | xclip -t 'image/png' -selection clipboard
        ;;
      *)
        echo 'Usage: screenshot <area/full/wind>'
        exit 1;
        ;;
    esac;
  }

  screenshot "$1"
''
