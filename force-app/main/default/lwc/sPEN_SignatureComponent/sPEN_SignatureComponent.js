import { LightningElement, api } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class SignatureDemo extends LightningElement {
	imgSrc;
	output;
	output2;
	@api recordId;
	@api signatureLabel; 
	
	renderedCallback() {
		document.fonts.forEach((font) => {
		if (font.family === "Great Vibes" && font.status === "unloaded") {
			// Ensure that the font is loaded so that signature pad could use it.
			// If you are using a different font in your project, don't forget
			// to update the if-condition above to account for it.
			font.load();
		}
		});
	}

	@api saveSignature() {
		const pad = this.template.querySelector("c-s-p-e-n_-signature-pad");
		if (pad) {
		const dataURL = pad.getSignature();
		if (dataURL) {
			// At this point you can consume the signature, for example by saving
			// it to disk or uploading it to a Salesforce org/record.
			// Here we just preview it in an image tag.
			const convertedDataURI = dataURL.replace(/^data:image\/(png|jpg);base64,/, "");


			this.dispatchEvent(new CustomEvent('savesignature', {
			detail: {
				message: dataURL,
				message2: convertedDataURI
			}
			}));

			this.output = convertedDataURI; 
			this.imgSrc = dataURL;
			}
		}
	}

	clearSignature() {
		const pad = this.template.querySelector("c-s-p-e-n_-signature-pad");
		if (pad) {
		pad.clearSignature();
		}

		this.imgSrc = null;

		this.dispatchEvent(new CustomEvent('cleansignature', {
		}));
	}
}