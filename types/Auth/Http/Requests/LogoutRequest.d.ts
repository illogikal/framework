export default class LogoutRequest extends FormRequest {
    authorize(): boolean;
    persist(): Promise<any>;
}
import FormRequest from "../../../Http/Request/FormRequest";
