import { $, echo, os } from 'zx'
import ipp from "ipp";
import { PDFDocument } from 'pdf-lib'
import { arrayBuffer } from 'node:stream/consumers';
import fs from "fs-extra";
import * as pdfjsLib from "pdfjs-dist";
import express from 'express';

const port = 7323
const app = express()
app.use(express.json())
app.use(express.raw({ type: "application/pdf" }));
app.listen(port, () => {
    console.log(`listening on :${port}`)
})

app.get("/", async (req, res) => {
    res.send("all good")
})
app.post("/", async (req, res) => {
    if (req.body instanceof Buffer) {
        if (req.body.length > 0) {
            try {
                const response = await nameMeLater(req.body)
                res.type("text/plain").send(response)
            } catch (e) {
                res.status(500).send(e)
            }
        } else {
            res.status(400).send("zero size body")
        }
    } else {
        res.status(400).send(`unsupported MIME: ${req.headers['content-type']}`)
    }
})

async function nameMeLater(input: Buffer) {
    const pdfjs = await pdfjsLib.getDocument(new Uint8Array(input)).promise
    const firstPage = await pdfjs.getPage(1)
    const firstPageText = (await firstPage.getTextContent()).items.reduce((result: string[], item) =>
        "str" in item ? [...result, item.str] : result
        , [])

    return `${JSON.stringify(firstPageText, null, 2)}`
}



async function printModify(input: PDFDocument) {
    $`qpdf Test-pdf_3.pdf.pdf --pages . 1-z --`

    const pdf = await fs.readFile('myfile2.pdf');

    const printer = new ipp.Printer("http://192.168.100.253:631/ipp/printer")

    printer.execute("Print-Job", {
        "operation-attributes-tag": {
            "requesting-user-name": "William",
            "job-name": "My Test Job",
            "document-format": "application/pdf"
        },
        "job-attributes-tag": {
            "sides": "two-sided-long-edge",
            "media-col": {
                "media-source": "tray-3"
            }
        },
        data: pdf
    }, function (err, res) {
        console.log(res);
    });
}

