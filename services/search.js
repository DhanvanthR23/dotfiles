.pragma library

function isSubsequence(needle, s) {
    let i = 0;
    for (let j = 0; j < s.length && i < needle.length; j++) {
        if (s[j] === needle[i])
            i++;
    }
    return i === needle.length;
}

// 6 prefix, 5 word prefix, 4 acronym, 3 substring, 2 extra text, 1 fuzzy, 0 no match
function tier(needle, name, extra) {
    const s = name.toLowerCase();
    if (s.startsWith(needle))
        return 6;

    const words = s.split(/[\s\-_.]+/).filter((w) => w !== "");
    if (words.some((w) => w.startsWith(needle)))
        return 5;

    // "vsc" -> Visual Studio Code
    if (needle.length >= 2 && words.map((w) => w[0]).join("").startsWith(needle))
        return 4;

    if (s.includes(needle))
        return 3;

    if (extra.toLowerCase().includes(needle))
        return 2;

    // "ffx" -> Firefox. Needs 3+ chars and a first letter that starts a word, or junk floods the list
    if (needle.length >= 3 && words.some((w) => w[0] === needle[0]) && isSubsequence(needle, s))
        return 1;

    return 0;
}
