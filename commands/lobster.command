//Help function:
exports.help = (config, command, message) => {
    return "Find an image of a lobster. \nUsage: \`" + config.prefix + command + "\`";
}
//Command logic:
exports.call = (args, info) => {
    var cheerio = require ("cheerio");
    var request = require ("request");
    function randomIntFromInterval (min, max) {
        return Math.floor (Math.random () * (max - min + 1) + min);
    }
    var options = {
        url: "http://results.dogpile.com/serp?qc=images&q=lobster",
        method: "GET",
        headers: {
            "Accept": "text/html",
            "User-Agent": "Chrome"
        }
    };
    request (options, function (error, response, responseBody) {
        $ = cheerio.load (responseBody);
        var links = $(".image a.link")
        var urls = new Array (links.length) . fill (0) . map ((v, i) => links.eq (i) . attr ("href"));
        if (!urls.length) {
            return "What the fuck? Why are there no images for lobsters? Bullshit. (Also this should not happen.)";
        }
        global.selected_lobster;
        global.selected_lobster = urls [Math.floor (Math.random () * urls.length)];
        console.log (selected_lobster);
    });
    return (global.selected_lobster);
}
