import { $, fs } from 'zx'
import ipp from "ipp";

const date = await $`date`
await $`echo Current date is ${date}.`

const pdf = fs.readFileSync('myfile.pdf', "binary");

const printer = new ipp.Printer("http://NPI977E4E.local.:631/ipp/printer")
var msg = {
    "operation-attributes-tag": {
        "requesting-user-name": "William",
        "job-name": "My Test Job",
        "document-format": "application/pdf"
    },
    data: pdf
};
//was Print-Job
printer.execute("Create-Job", msg, function (err, res) {
    console.log(res);
});