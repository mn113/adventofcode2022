<script>
    // This Svelte file from https://svelte.dev/repl/d693dc38eb9e4229826c6a812611996e?version=3.55.0
    // doesn't solve the AoC puzzle, but generates a nice visualisation.

    // [x, y, size, color]
    const data = [
        [2000000, 2000000, 2000000], // calibration diamond - should be centred and fill height & width
        [45969,   76553,   1938058, 'purple'],
        [3998240, 15268,   1931751, 'salmon'],
        [1615638, 1108834, 1882770, 'teal'],
        [3304786, 844925,  1502817, 'aqua'],
        [404933,  3377916, 1434027, 'red'],
        [980874,  2369046, 1318562, 'green'],
        [1183930, 3997648, 1274762, 'darkgrey'],
        [3829801, 2534117, 1128488, '#c0ffee'],
        [1926292, 193430,  1116775, 'orange'],
        [3993022, 3910207, 1012683, 'steelblue'],
        [3009341, 3849969, 1007824, 'limegreen'],
        [3028318, 3091480, 770748,  'red'],
        [2286195, 3134541, 690610,  'lightpink'],
        [2391367, 3787759, 612816,  'red'],
        [2916267, 2516612, 557389,  'cyan'],
        [1826659, 2843839, 521776,  'orange'],
        [2360813, 2494240, 493995,  'tan'],
        [3475687, 3738894, 430403,  'lavender'],
        [3793239, 3203486, 422557,  'orange'],
        [258318,  2150378, 377338,  'lawngreen'],
        [2647492, 1985479, 301445,  'salmon'],
        [15629,   2015720, 31449,   'fuchsia'],
        [15626,   1984269, 31463,   'lightblue'],
    ];
    const mult = Math.sqrt(2)/2; // use in diagonal dir
    // upscale squares so that vertical rendered distances equal diagonal manhattan distances
    const inverseMult = 1/mult; // use in x-y dirs

    let c = 2000000;
    let s = 500000
</script>

<style>
    :root {
        background: white;
    }
    svg {
        border: 1px solid black;
        margin: auto;
    }
</style>

<svg width="500" height="500" viewBox="0 0 4000000 4000000" xmlns="http://www.w3.org/2000/svg">
    <g style="fill-opacity:0.8;">
        {#each data.slice(1,24) as [cx, cy, size, color]}
            <circle {cx} {cy} r={2500} fill={color} />
            <rect x={cx} y={cy - size} width={3000} height={size * 2}></rect>
            <rect x={cx - size} y={cy} width={size * 2} height={3000}></rect>
            <rect x={cx} y={cy}
                width={size * mult * 2} height={size * mult * 2}
                transform={`rotate(45 ${cx} ${cy}) translate(${-mult * size} ${-mult * size})`}
                style="fill:{color};opacity:0.7"/>
        {/each}
    </g>
    <text x="2000" y="8000" style="font-size:6000px;fill:red;" transform="scale(20)">(0,0)</text>
</svg>
