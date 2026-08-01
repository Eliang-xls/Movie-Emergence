# 35mm Photograph — AI Image-Gen Prompt (English)

> Source / Prototype: `08_设定/04_叙事与视觉设计/04_照片具象化影像设计.md`
> Storyboard anchor: Flow `flow_script_EN_v2.txt` → **Scene 08 / T8** (the `0.5s Flash-cut` of the old 35mm photograph dated **"2042.11"**, front image overlaid / matched against Ji Shen's **L8 four fields**).
> Role in the film: a *"decodable physical evidence"* — a man hid an address inside his aesthetic of the world, then quietly waited (until Ji Yao walks into that wall in Chapter 64).

---

## PRIMARY PROMPT — The photograph (front, the landscape)

```
A 4:3 analog 35mm film photograph, shot from inside an old Chinese coastal
home looking out through a window at eye level — the viewer stands exactly
where Ji Shen once stood. Lower third foreground: the interior wall of the
old house, mottled lime plaster faded to grey-green and ochre-yellow, decades
of layered repainting; beneath the topmost coat, irregular hand-trowel repair
marks faintly show through — someone scraped the wall but left it unsmoothed
before painting over. Mid-ground: a three-meter-wide old stone-slab path,
grey-white flagstones, wild grass grown thick in the seams where no one has
walked for half a month, the path gently leading the eye toward the sea.
Background: the East China Sea at an early winter morning, vast and silent,
silver-blue water; a low southern sun casting a thin diagonal pale-gold light
across the surface — an east-facing, winter dawn. Sky: completely empty — no
birds, no boats, no movement — only one extremely thin, motionless cloud
resting on the horizon. Texture: visible 35mm film grain, subtle light leak
at the edges, soft-focus vignette with faint sprocket-hole darkening in the
corners; overall low saturation — blue-grey, warm grey, faded ochre, a single
thread of morning gold. Mood of Hirokazu Koreeda's still long takes crossed
with Andrei Tarkovsky's suspended time. Photorealistic, analog film stock,
Kodak Portra 400, restrained, contemplative, melancholy. --ar 4:3 --style raw
```

**Negative prompt:**
```
no people, no figures, no portraits, no text, no letters, no handwriting,
no modern objects, no cars, no phone, no electrical wires, no vivid or
saturated colors, no tourist-postcard feel, no dramatic sky, no sunset
fire, no lens flare, no HDR, no CGI, no anime, no painting
```

---

## SECONDARY PROMPT — Reverse side (the "2042.11" date)

```
Extreme close-up of the reverse of an old 35mm photograph, cream paper aged
to pale yellow with slight curling at the corners and faint foxing. A
handwritten date "2042.11" in blue ballpoint pen, written with steady,
deliberate pressure — the hand was calm when it wrote. A few soft fingerprint
smudges near the edge. Soft north-window daylight, fine analog film-grain
texture, minimalist, intimate, quiet. --ar 4:3 --style raw
```

---

## OPTIONAL — Composite for the T8 flash-cut (photo + L8 data-field overlay)

This is a motion-graphics / compositing brief rather than a single image prompt.
In the trailer the **front photo** is briefly overlaid with Ji Shen's four L8
fields (the four lines of his philosophy) for under half a second, as if Ji Hang
is comparing and matching them. If you want one still that pre-visualizes it:

```
The 35mm coastal-house photograph described above, with four faint monospaced
data-field labels softly overprinted in the margins like a forensic annotation
layer — thin cyan (#4A6B8A) hairline frame, minimal pixelated type, semi-
transparent so the landscape still reads through. Evidence-matching aesthetic,
subtle, not sci-fi. --ar 4:3 --style raw
```

---

## Why these choices (design fidelity)

| Design doc requirement | How it appears in the prompt |
|---|---|
| 画幅 4:3 / 仿35mm胶卷 / 齿孔暗角 | `--ar 4:3`, sprocket-hole vignette, film grain |
| 视角：老宅内向窗外平视 | "from inside an old home looking out at eye level" |
| 前景下三分之一·斑驳石灰墙+刮刀痕 | lower-third interior wall, hand-trowel repair marks = "three iterations" |
| 中景·三米宽石板路+野草 | 3m stone-slab path, grass in seams (no one walked ½ month) |
| 远景·东海清晨银蓝+淡金斜光 | East China Sea, silver-blue, low southern sun, pale-gold diagonal |
| 天空空无一物+一线静止云 | empty sky, one thin motionless horizon cloud (= clean baseline, SNR>3:1) |
| 质感：颗粒/漏光/柔焦/低饱和 | grain, light leak, soft-focus, low-saturation palette |
| 禁忌：无人/无文字/无现代物/无艳色/无景点感 | full negative prompt enforces all five taboos |
| 气质：是枝裕和+塔可夫斯基 | explicitly named in the prompt for model guidance |
```
