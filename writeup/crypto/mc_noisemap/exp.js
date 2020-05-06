/**
* @Author: impakho
* @Date: 2020/04/14
* @Github: https://github.com/impakho
*/

const http = require('http');
const path = require('path');
const fs = require('fs');
const gen = require('random-seed');
const { Cluster } = require('puppeteer-cluster');
const sharp = require('sharp');

const IMAGE_NUM = 32;
const GEN_TIME = 1587019061;
const PORT = 80;

var reqWhiteList = [
  '/assets/jquery.min.js',
  '/assets/noisemap.js',
  '/assets/p5.dom.js',
  '/assets/p5.js'
];

function reqFile(res, pathname, html) {
  fs.readFile(pathname,
    function (err, data) {
      if (err) {
        res.writeHead(404);
        return res.end('404 not found');
      }

      var ext = path.extname(pathname);

      var typeExt = {
        '.html': 'text/html',
        '.js':   'text/javascript',
        '.css':  'text/css'
      };

      var contentType = typeExt[ext] || 'text/plain';

      res.writeHead(200, { 'Content-Type': contentType });
      res.write(data);
      res.end(html);
    }
  );
}

function handleRequest(req, res) {
  var pathname = req.url;
  //console.log(pathname);

  if (reqWhiteList.includes(pathname)) {
    var html = '';

    reqFile(res, 'www' + pathname, html);
    return;
  }

  if (pathname.substring(0, 10) === "/map?seed=") {
    var seed = pathname.substring(10);

    seed = parseInt(seed);

    var html = '';

    html = '<script>var seed = ' + seed + ';</script>';

    reqFile(res, 'www/map.html', html);
    return;
  }

  res.writeHead(404);
  res.end('404 not found');
}

var server = http.createServer(handleRequest);
server.listen(PORT);

function getHash(img_data) {
  var data = [...img_data];
  var offset = 0;
  var hash1 = [];
  while (true) {
    offset += 520 * 8 * 3;
    if (offset + 520 * 3 > data.length) break;
    hash1 = hash1.concat(data.slice(offset, offset + 520 * 3));
  }
  var hash2 = [];
  for (var i = 0; i < hash1.length / 64; i++) {
    hash2.push(hash1[i * 64]);
  }
  return hash2;
}

function hashCompare(hash1, hash2) {
  var length = hash1.length < hash2.length ? hash1.length : hash2.length;
  var distance = 0;
  for (var i = 0; i < length; i++) {
    var diff = hash1[i] ^ hash2[i];
    for (var j = 0; j < 8; j++) {
      distance += diff & 1;
      diff >>= 1;
    }
  }
  return distance;
}

var img_modify = {};

for (var i = 0; i < IMAGE_NUM; i++) {
  var data = fs.readFileSync('maps/' + i + '.webp');
  (async () => {
    img_modify[i] = getHash(await sharp(data).raw().toBuffer());
  })();
}

var img_origin = {};

(async () => {
  const cluster = await Cluster.launch({
    concurrency: Cluster.CONCURRENCY_PAGE,
    maxConcurrency: 4,
    puppeteerOptions: {
      defaultViewport: {
        width: 520,
        height: 520
      }
    }
  });

  await cluster.task(async ({ page, data }) => {
    await page.goto('http://127.0.0.1:' + PORT + '/map?seed=' + data.seed);
    img_origin[data.id] = getHash(await sharp(await page.screenshot()).removeAlpha().webp().raw().toBuffer());
  });

  for (var i = 0; i < 0x10000; i++) {
    cluster.queue({id: i, seed: i});
  }

  await cluster.idle();
  await cluster.close();

  await compareAll();
})();

function isPrintable(char) {
  if (char >= 0x20 && char < 0x7f) return true;
  return false;
}

function groupsToPlain(groups, time) {
  while (true) {
    var rand = gen.create(time);
    var items = [];
    for (var i = 0; i < groups.length; i++) {
      var item = [];
      var r1 = rand.range(0x100);
      var r2 = rand.range(0x100);
      var low = groups[i] & 0xff;
      var high = (groups[i] >> 8) & 0xff;
      var a1 = (high + low) / 2;
      var a2 = ((high + low + 0x100) / 2) & 0xff;
      if (a1 < 0x100) {
        var b1 = a1 + low;
        var b2 = (a1 - low) & 0xff;
        if (b1 < 0x100 && ((b1 + a1) & 0xff) == high) {
          if (isPrintable(b1 ^ r1) && isPrintable(a1 ^ r2)) item.push([b1 ^ r1, a1 ^ r2]);
        }
        if (b2 < 0x100 && ((b2 + a1) & 0xff) == high) {
          if (isPrintable(b2 ^ r1) && isPrintable(a1 ^ r2)) item.push([b2 ^ r1, a1 ^ r2]);
        }
      }
      if (a2 < 0x100) {
        var b1 = a2 + low;
        var b2 = (a2 - low) & 0xff;
        if (b1 < 0x100 && ((b1 + a2) & 0xff) == high) {
          if (isPrintable(b1 ^ r1) && isPrintable(a2 ^ r2)) item.push([b1 ^ r1, a2 ^ r2]);
        }
        if (b2 < 0x100 && ((b2 + a2) & 0xff) == high) {
          if (isPrintable(b2 ^ r1) && isPrintable(a2 ^ r2)) item.push([b2 ^ r1, a2 ^ r2]);
        }
      }
      if (item.length <= 0) break;
      items.push(item);
    }
    if (items.length == groups.length) {
      return items;
    }
    time++;
  }
}

function formatPlain(plain) {
  var all = '';
  for (var i = 0; i < plain.length; i++) {
    var each = '';
    for (var j = 0; j < plain[i].length; j++) {
      if (each != '') each += '/';
      each += String.fromCharCode(plain[i][j][0])
      each += String.fromCharCode(plain[i][j][1])
    }
    if (each.indexOf('/') != -1 && i != plain.length - 1) each += ',';
    all += each;
  }
  return all;
}

function compareAll() {
  var groups = [];
  for (var i = 0; i < IMAGE_NUM; i++) {
    var min_match = -1;
    var min_diff = 0xffffffff;
    for (var j = 0; j < 0x10000; j++) {
      var diff = hashCompare(img_origin[j], img_modify[i]);
      if (diff < min_diff) {
        min_match = j;
        min_diff = diff;
      }
      if (diff == 0) break;
    }
    groups.push(min_match);
  }
  console.log(groups);
  var plain = groupsToPlain(groups, GEN_TIME);
  console.log(plain);
  console.log(formatPlain(plain));
}

function readProgress() {
  console.log(Object.keys(img_origin).length + ' / ' + 0x10000);
  if (Object.keys(img_origin).length < 0x10000) {
    setTimeout(readProgress, 500);
  }
}

setTimeout(readProgress, 500);