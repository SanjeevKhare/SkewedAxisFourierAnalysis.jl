<script setup>
import { computed, ref } from 'vue'

const angle = ref(120)
const θ = computed(() => Number(angle.value) * Math.PI / 180)
const palette = [[68, 1, 84], [59, 82, 139], [33, 145, 140], [94, 201, 98], [253, 231, 37]]
function color(value) {
  const t = Math.max(0, Math.min(3.999, (value + .15) / 1.9 * 4))
  const k = Math.floor(t), w = t - k
  return `rgb(${palette[k].map((c, i) => Math.round(c * (1 - w) + palette[k + 1][i] * w)).join(',')})`
}
const cells = computed(() => {
  const result = []
  const sin = Math.sin(θ.value), cos = Math.cos(θ.value)
  for (let row = 0; row < 48; row++) {
    for (let col = 0; col < 64; col++) {
      const x = -.5 + (col + .5) / 64 * 2
      const y = (47 - row + .5) / 48 * 1.5
      const U = x + y * cos / sin, V = y / sin
      const f = .8 + .65 * Math.cos(2 * Math.PI * (2 * U + V) + .4)
        + .30 * Math.cos(2 * Math.PI * (-U + 3 * V) - .6)
      result.push({ x: col * 6.25, y: row * 6.25, fill: color(f) })
    }
  }
  return result
})
const cellOutline = computed(() => {
  const c = Math.cos(θ.value), s = Math.sin(θ.value)
  return [[0, 0], [1, 0], [1 - c, s], [-c, s], [0, 0]]
    .map(([x, y]) => `${(x + .5) * 200},${300 - y * 200}`).join(' ')
})
</script>

<template>
  <div class="angle-explorer">
    <div class="angle-controls">
      <p class="angle-kicker">ONE MODEL · MANY PERSPECTIVES</p>
      <h3>Move the angle.<br>Follow the unit cell.</h3>
      <p>The coefficients stay fixed. Only the map from Cartesian space to the periodic coordinates changes.</p>
      <label for="skew-angle">Reconstruction parameter <strong>θ = {{ angle }}°</strong></label>
      <input id="skew-angle" v-model="angle" type="range" min="30" max="150" step="1" aria-label="Reconstruction angle in degrees">
      <div class="angle-extents"><span>30°</span><span>90°</span><span>150°</span></div>
      <p class="angle-caption">Included basis angle: <strong>{{ 180 - Number(angle) }}°</strong><br>White outline: one periodic cell.</p>
      <button type="button" @click="angle = 90">Try orthogonal axes</button>
    </div>
    <figure>
      <svg viewBox="0 0 400 300" role="img" :aria-label="`Analytic periodic field at reconstruction angle ${angle} degrees`">
        <rect v-for="(cell, k) in cells" :key="k" :x="cell.x" :y="cell.y" width="6.4" height="6.4" :fill="cell.fill" />
        <polyline :points="cellOutline" fill="none" stroke="white" stroke-width="2" />
      </svg>
      <figcaption>Same two-mode analytic field as Tutorial 03. Fixed color scale: −0.15 to 1.75.</figcaption>
    </figure>
  </div>
</template>

<style scoped>
.angle-explorer { display: grid; grid-template-columns: 1fr 1.15fr; gap: 28px; padding: 28px; margin: 28px 0; border: 1px solid var(--vp-c-divider); border-radius: 18px; background: var(--vp-c-bg-soft); }
.angle-kicker { font-size: 10px; letter-spacing: .1em; font-weight: 700; color: var(--vp-c-brand-1); margin: 0 0 14px; }
h3 { font-size: 25px; letter-spacing: -.035em; line-height: 1.2; margin: 0 0 14px; }
p { font-size: 14px; line-height: 1.7; color: var(--vp-c-text-2); }
label { display: flex; flex-wrap: wrap; justify-content: space-between; gap: 8px; margin-top: 24px; font-size: 13px; }
label strong { color: var(--vp-c-brand-1); }
input { display: block; width: 100%; margin: 18px 0 8px; accent-color: var(--vp-c-brand-1); cursor: pointer; }
input:focus-visible, button:focus-visible { outline: 3px solid var(--vp-c-brand-1); outline-offset: 4px; }
.angle-extents { display: flex; justify-content: space-between; font-size: 11px; color: var(--vp-c-text-2); }
.angle-caption { font-size: 12px; }
button { border: 1px solid var(--vp-c-divider); border-radius: 8px; padding: 6px 12px; background: var(--vp-c-bg); color: var(--vp-c-brand-1); font-size: 12px; cursor: pointer; }
figure { margin: 0; align-self: center; min-width: 0; }
svg { display: block; width: 100%; border-radius: 10px; overflow: hidden; }
figcaption { margin-top: 10px; color: var(--vp-c-text-2); font-size: 11px; line-height: 1.6; }
@media (max-width: 720px) { .angle-explorer { grid-template-columns: 1fr; padding: 20px; } }
</style>
