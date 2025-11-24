abbr -a -- hx helix

abbr -a --position anywhere --function last_history_item -- !!

abbr -a -- tremd transmission-daemon
abbr -a -- trem transmission-remote

abbr -a cam -- mpv --demuxer-lavf-o=video_size=2560x1440,input_format=mjpeg av://v4l2:/dev/video0 --profile=low-latency --untimed --vf=hflip,vflip focus_automatic_continuous=0

abbr -a rmed -- 'while fd -td -te | rg .; fd -td -te -x rm -r; end'

abbr -a p -- paru --removemake=yes --devel --nokeepsrc -Syu
abbr -a pa -- paru

abbr -a se -- sudo -E helix
abbr -a e -- helix

abbr -a t -- task
abbr -a ta -- task add
abbr -a tp -- task status:pending

abbr -a tproj --set-cursor=_ --command task --regex p "proj:_"
abbr -a tspend --set-cursor=_ --command task --regex sp "status:pending _"
abbr -a tsdel --set-cursor=_ --command task --regex sd "status:deleted _"
abbr -a tscomp --set-cursor=_ --command task --regex sc "status:completed _"
abbr -a td --command task --regex r del
abbr -a tc --command task --regex d done
abbr -a ta2 --command task --regex a add
abbr -a db --set-cursor=_ --command task --regex db "due.before:_"

abbr -a cm -- chezmoi
abbr -a cme -- chezmoi edit
abbr -a cmc -- z ~/.local/share/chezmoi/

abbr -a chezmoiapply --set-cursor=_ --command chezmoi --regex a "apply _"
abbr -a chezmoiapplyp --set-cursor=_ --command chezmoi --regex ap "apply -p _"
