#!/bin/bash

source ~/.gpt3/key.sh

play /usr/lib/libreoffice/share/gallery/sounds/apert.wav &

# Put the selected text into a variable.
selection=$(xsel -o)

# JSON escape
selection=$(echo "$selection" | sed 's/\(["\]\)/\\\1/g')

# If nothing is selected, quit.
if [ -z "$selection" ]; then
    exit
fi

jsonOutput=$(curl https://api.openai.com/v1/engines/code-davinci-002/completions \
                  -H "Authorization: Bearer $OPENAI_API_KEY" \
                  -H "Content-Type: application/json" \
                  -d "{\"prompt\": \"Correct C++ code if needed:\\n\\n${selection//$'\n'/\\n}\\nCorrected:\",\"max_tokens\": 3000,\"temperature\": 0.0,\"top_p\": 1.0,\"frequency_penalty\": 0.0,\"presence_penalty\":0.0,\"stop\": [\"*/\",\"Correct C++ code if needed\"]}" 2> /dev/null)

# Extract the result from jsonOutput.
result=$(echo "$jsonOutput" | jq -r '.choices[0].text')

# Remove leading spaces in each line.
result=$(echo "$result" | sed 's/^[ \t]*//')

# Paste using xdotool.
xdotool type --delay 25 --clearmodifiers "${result:1}"
