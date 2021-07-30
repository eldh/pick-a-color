import MarkdownIt from "markdown-it";
const md = new MarkdownIt();
const result = md.render("# markdown-it rulezz!");
console.log(result);
