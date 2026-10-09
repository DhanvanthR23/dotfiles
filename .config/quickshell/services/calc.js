.pragma library

// expr  = term (('+' | '-') term)*
// term  = unary (('*' | '/' | '%') unary)*
// unary = '-' unary | power
// power = atom ('^' unary)?
// atom  = number | '(' expr ')'

function tokenize(s) {
    const tokens = [];
    const re = /\d+\.?\d*|\.\d+|[-+*\/%^()]/g;
    let m;
    let last = 0;
    while ((m = re.exec(s)) !== null) {
        if (m.index !== last)
            return null; // junk between tokens
        tokens.push(m[0]);
        last = re.lastIndex;
    }
    return last === s.length ? tokens : null;
}

// returns a number, or null if the input isn't a valid expression
function evaluate(input) {
    const tokens = tokenize(input.replace(/\s+/g, ""));
    if (!tokens || tokens.length === 0)
        return null;

    let pos = 0;
    const peek = () => tokens[pos];
    const next = () => tokens[pos++];

    function expr() {
        let v = term();
        while (peek() === "+" || peek() === "-")
            v = next() === "+" ? v + term() : v - term();
        return v;
    }

    function term() {
        let v = unary();
        while (peek() === "*" || peek() === "/" || peek() === "%") {
            const op = next();
            const r = unary();
            v = op === "*" ? v * r : op === "/" ? v / r : v % r;
        }
        return v;
    }

    function unary() {
        if (peek() === "-") {
            next();
            return -unary();
        }
        return power();
    }

    function power() {
        const base = atom();
        if (peek() === "^") {
            next();
            return Math.pow(base, unary());
        }
        return base;
    }

    function atom() {
        const t = next();
        if (t === "(") {
            const v = expr();
            if (next() !== ")")
                throw new Error("expected )");
            return v;
        }
        const n = parseFloat(t);
        if (t === undefined || isNaN(n))
            throw new Error("unexpected token");
        return n;
    }

    try {
        const v = expr();
        return pos === tokens.length && isFinite(v) ? v : null;
    } catch (e) {
        return null;
    }
}
