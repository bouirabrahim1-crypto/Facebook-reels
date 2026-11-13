#!/bin/bash
set -e
cd "$(dirname "$0")/../../.."   # -> projects/morocco-vegetable-export-ban
PROJ="$(pwd)"
FOOTAGE="$PROJ/assets/footage"
VOICE="$PROJ/assets/voiceover"
RENDERS="$PROJ/assets/renders"
mkdir -p "$RENDERS"

echo "== 1/4: concatenating 6 scenes (video+audio) =="
ffmpeg -y \
  -i "$FOOTAGE/hook.mp4"          -i "$VOICE/hook.mp3" \
  -i "$FOOTAGE/decision.mp4"      -i "$VOICE/decision.mp3" \
  -i "$FOOTAGE/reason.mp4"        -i "$VOICE/reason.mp3" \
  -i "$FOOTAGE/farmers.mp4"       -i "$VOICE/farmers.mp3" \
  -i "$FOOTAGE/committee.mp4"     -i "$VOICE/committee.mp3" \
  -i "$FOOTAGE/conclusion.mp4"    -i "$VOICE/conclusion.mp3" \
  -filter_complex "\
[0:v]format=yuv420p[v0];[1:a]aformat=sample_rates=48000:channel_layouts=stereo[a0];\
[2:v]format=yuv420p[v1];[3:a]aformat=sample_rates=48000:channel_layouts=stereo[a1];\
[4:v]format=yuv420p[v2];[5:a]aformat=sample_rates=48000:channel_layouts=stereo[a2];\
[6:v]format=yuv420p[v3];[7:a]aformat=sample_rates=48000:channel_layouts=stereo[a3];\
[8:v]format=yuv420p[v4];[9:a]aformat=sample_rates=48000:channel_layouts=stereo[a4];\
[10:v]format=yuv420p[v5];[11:a]aformat=sample_rates=48000:channel_layouts=stereo[a5];\
[v0][a0][v1][a1][v2][a2][v3][a3][v4][a4][v5][a5]concat=n=6:v=1:a=1[outv][outa]" \
  -map "[outv]" -map "[outa]" -c:v libx264 -crf 18 -pix_fmt yuv420p -c:a aac \
  "$RENDERS/body.mp4"

echo "== 2/4: overlay watermark =="
ffmpeg -y -i "$RENDERS/body.mp4" -i "$PROJ/../../brand/assets/sy-watermark.png" \
  -filter_complex "[1:v]scale=160:160[wm];[0:v][wm]overlay=W-w-50:H-h-120" \
  -c:a copy "$RENDERS/branded_body.mp4"

echo "== 3/4: prepare intro + outro with silent audio =="
ffmpeg -y -i "$PROJ/../../templates/intro/intro.mp4" -f lavfi -i "anullsrc=channel_layout=stereo:sample_rate=48000" \
  -c:v copy -c:a aac -shortest -t 3.0 "$RENDERS/intro_with_audio.mp4"

ffmpeg -y -i "$PROJ/../../templates/outro/outro.mp4" -f lavfi -i "anullsrc=channel_layout=stereo:sample_rate=48000" \
  -c:v copy -c:a aac -shortest -t 3.5 "$RENDERS/outro_with_audio.mp4"

echo "== 4/4: prepend intro, concat all, append outro =="
ffmpeg -y -i "$RENDERS/intro_with_audio.mp4" -i "$RENDERS/branded_body.mp4" -i "$RENDERS/outro_with_audio.mp4" \
  -filter_complex "\
[0:v]format=yuv420p[v0];[0:a]aformat=sample_rates=48000:channel_layouts=stereo[a0];\
[1:v]format=yuv420p[v1];[1:a]aformat=sample_rates=48000:channel_layouts=stereo[a1];\
[2:v]format=yuv420p[v2];[2:a]aformat=sample_rates=48000:channel_layouts=stereo[a2];\
[v0][a0][v1][a1][v2][a2]concat=n=3:v=1:a=1[outv][outa]" \
  -map "[outv]" -map "[outa]" -c:v libx264 -crf 18 -pix_fmt yuv420p -c:a aac \
  "$RENDERS/final_video.mp4"

echo "done -> $RENDERS/final_video.mp4"
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1 "$RENDERS/final_video.mp4"
