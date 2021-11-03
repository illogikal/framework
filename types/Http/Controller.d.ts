export default class Controller {
    /**
         * Throw a 404 exception.
         *
         * @throws {NotFoundException}
         */
    /**
    *
         * Throw a 404 exception.
         *
         * @throws {NotFoundException}
         
    @param {String} message
    */
    notFound(message?: string): void;
    /**
         * Throw a 400 exception.
         *
         * @throws {HttpException}
         */
    /**
    *
         * Throw a 400 exception.
         *
         * @throws {HttpException}
         
    @param {String} message
    */
    badRequest(message?: string): void;
    /**
         * Render a view.
         */
    /**
    *
         * Render a view.
         
    @param {Function|View} view
    @param {Object} data
    */
    view(view: Function | any, data?: any): ViewResponse;
    /**
         * Validate request.
         */
    /**
    *
         * Validate request.
         
    @param {FormRequest|Request} request
    @param {Object} rules
    */
    validate(request: any | Request, rules?: any): any;
}
import ViewResponse from "./Response/ViewResponse";
