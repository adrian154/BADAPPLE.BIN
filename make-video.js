// --- warning: this code is trash ---
const fs = require("fs");
const data = fs.readFileSync("resources/font.ppm").subarray(0x0f);

const brightnesses = [0, 0, 0, 0, 0, 0, 0, 170, 85, 0, 0, 0, 0, 0, 0, 255];
const combos = [];

for(let glyph = 1; glyph < 256; glyph++) {
    
    const row = Math.floor(glyph / 80),
          col = glyph % 80;
    
    // chars are 8 pixels wide but there's 1 pixel of spacing in between
    let onPixels = 0;
    for(let x = col * 9; x < col * 9 + 8; x++) {
        for(let y = row * 16; y < row * 16 + 16; y++) {
            if(data[(y * 720 + x) * 3] != 0) {
                onPixels++;
            }
        }
    }

    // figure out the best combo
    for(const bg of [0, 7]) {
        for(const fg of [0, 7, 8, 15]) {
            const onFraction = onPixels / 128;
            const avgColor = (1 - onFraction) * brightnesses[bg] + onFraction * brightnesses[fg];
            combos.push([(bg<<4|fg)<<8|glyph, avgColor]);       
        }
    }

}

const bestCombos = new Array(256);
for(let color = 0; color < 256; color++) {
    let min = Infinity,
        best = null;
    for(const combo of combos) {
        const diff = Math.abs(combo[1] - color);
        if(diff < min) {
            min = diff;
            best = combo;
        }
    }
    bestCombos[color] = best[0];
}

const frameCount = fs.readdirSync("resources/frames").filter(name => name.match(/\d+\.ppm/)).length;
const video = Buffer.alloc(frameCount * 4096);

for(let i = 0; i < frameCount; i++) {
    const frame = fs.readFileSync(`resources/frames/${i + 1}.ppm`).subarray(0x0d);
    console.log(i);
    for(let idx = 0; idx < 2000; idx++) {
        const color = Math.floor((frame[idx*3] + frame[idx*3+1] + frame[idx*3+2])/3);
        const combo = bestCombos[frame[idx * 3]];
        video[idx * 2 + i * 4096] = combo & 0xff;
        video[idx * 2 + i * 4096 + 1] = combo >> 8;
    }
}

fs.writeFileSync("video.bin", video);