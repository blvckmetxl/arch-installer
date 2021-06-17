#!/bin/bash

mkdir -p ~/.config/mpd && cd ~/.config/mpd
touch database mpd.conf mpd.fifo mpd.log mpdstate

cat << EOF >> ~/.config/mpd/mpd.conf
db_file            "~/.config/mpd/database"
log_file	   "~/.config/mpd/mpd.log"
music_directory    "~/music"
pid_file           "~/.config/mpd/mpd.pid"
state_file         "~/.config/mpd/mpdstate"
audio_output {
        type            "pulse"
        name            "pulse audio"
}
audio_output {
    type		"fifo"
    name		"FIFO"
    path		"/tmp/mpd.fifo"
    format		"44100:16:2"
}
EOF

mkdir ~/.ncmpcpp && touch ~/.ncmpcpp/config

cat << EOF >> ~/.ncmpcpp/config
ncmpcpp_directory =         "~/.ncmpcpp"
mpd_host =                  "127.0.0.1"
mpd_port =                  "6600"
mpd_music_dir =	            "~/Música"
mpd_crossfade_time = 5
visualizer_fifo_path = "/tmp/mpd.fifo"
visualizer_output_name = "FIFO"
visualizer_in_stereo = "yes"
visualizer_sync_interval = "30"
visualizer_type = "wave"
visualizer_look = "●▮"
message_delay_time = "3"
playlist_shorten_total_times = "yes"
playlist_display_mode = "columns"
browser_display_mode = "columns"
search_engine_display_mode = "columns"
playlist_editor_display_mode = "columns"
autocenter_mode = "yes"
centered_cursor = "yes"
user_interface = "alternative"
follow_now_playing_lyrics = "yes"
locked_screen_width_part = "60"
display_bitrate = "yes"
external_editor = "vim"
use_console_editor = "yes"
header_window_color = "cyan"
volume_color = "yellow"
state_line_color = "yellow"
state_flags_color = "cyan"
progressbar_color = "yellow"
statusbar_color = "cyan"
visualizer_color = "cyan"
mouse_list_scroll_whole_page = "yes"
lines_scrolled = "1"
enable_window_title = "yes"
song_columns_list_format = "(25)[cyan]{a} (40)[]{f} (30)[red]{b} (7f)[green]{l}"
EOF
