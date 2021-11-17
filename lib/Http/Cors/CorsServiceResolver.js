function requireDefault$__(obj){
	return obj && obj.__esModule ? obj : { default: obj };
};;
function iter$__(a){ let v; return a ? ((v=a.toIterable) ? v.call(a) : a) : []; };
Object.defineProperty(exports, "__esModule", {value: true});

/*body*/
var _$NotFoundExceptionφ = requireDefault$__(require('../Exceptions/NotFoundException'/*$path$*/));
var _$isEmptyφ = requireDefault$__(require('../../Support/Helpers/isEmpty'/*$path$*/));
var _$fastify_corsφ = requireDefault$__(require('fastify-cors'/*$path$*/));
var _$ServiceResolverφ = requireDefault$__(require('../../Support/ServiceResolver'/*$path$*/));
class CorsServiceResolver extends _$ServiceResolverφ.default {
	
	
	/**
		 * Get allowed origins.
		 *
		 * @oaram {String} origin
		 * @returns {String[]}
		 */
	
	/**
	*
		 * Get allowed origins.
		 *
		 * @oaram {String} origin
		 * @returns {String[]}
		 
	@param {String} origin
	*/
	getOrigins(origin){
		
		const origins = [];
		const requestOrigin = origin.split('://')[1];
		
		for (let iφ = 0, itemsφ = iter$__(this.app.config.get('cors.allowed_origins')), lenφ = itemsφ.length; iφ < lenφ; iφ++) {
			let o = itemsφ[iφ];
			const incomingOrigin = requestOrigin.split('.');
			const allowedOrigin = o.includes('://') ? o.split('://')[1].split('.') : o.split('.');
			
			if (o === '*') { origins.push(origin) };
			
			if (o !== '*') {
				
				if (allowedOrigin.length === incomingOrigin.length) {
					
					let index = 0;
					let build = [];
					
					while (index < incomingOrigin.length){
						
						const match = (allowedOrigin[index] == '*') ? incomingOrigin[index] : allowedOrigin[index];
						
						build.push(match);
						
						index++;
					};
					
					origins.push(build.join('.'));
				};
			};
		};
		
		return origins;
	}
	
	/**
		 * Check if path matches allowed path's.
		 *
		 * @param {FastifyRequest} request
		 * @returns {Boolean}
		 */
	
	/**
	*
		 * Check if path matches allowed path's.
		 *
		 * @param {FastifyRequest} request
		 * @returns {Boolean}
		 
	@param {FastifyRequest} request
	*/
	isMatchingPath(request){
		
		const url = request.url.includes('?') ? request.url.split('?')[0] : request.url;
		
		for (let iφ2 = 0, itemsφ2 = iter$__(this.app.config.get('cors.paths')), lenφ2 = itemsφ2.length; iφ2 < lenφ2; iφ2++) {
			let path = itemsφ2[iφ2];
			if (path.endsWith('/*')) {
				
				const pathWithoutWildcard = path.substring(0,path.length - 2);
				const currentPath = url;
				
				if (currentPath.startsWith(pathWithoutWildcard)) {
					
					path = pathWithoutWildcard + currentPath.substring(currentPath.indexOf(pathWithoutWildcard) + pathWithoutWildcard.length);
				};
			};
			
			if (url == path) { return true };
		};
		
		return false;
	}
	
	/**
		 * Boot cors service resolver.
		 *
		 * @returns {void}
		 */
	
	/**
	*
		 * Boot cors service resolver.
		 *
		 * @returns {void}
		 
	*/
	boot(){
		var self = this;
		
		return self.app.register(_$fastify_corsφ.default,function() {
			
			return function(/**@type {FastifyRequest}*/request,callback) {
				
				const options = {
					origin: function(/**@type {String}*/origin,cb) {
						
						if (_$isEmptyφ.default(origin)) { return cb(null,true) };
						
						const requestOrigin = origin.split('://')[1];
						
						if (self.getOrigins(origin,self.app.config).includes(requestOrigin) && self.isMatchingPath(request,self.app.config)) {
							
							cb(null,true);
							return;
						};
						
						// If the origin is not allowed, or the path is not allowed, return a 404
						throw new _$NotFoundExceptionφ.default(("Route " + (request.method) + ":" + (request.url) + " not found."));
					},
					
					credentials: self.app.config.get('cors.supports_credentials'),
					maxAge: self.app.config.get('cors.max_age')
				};
				
				if (self.app.config.get('cors.allowed_methods') && self.app.config.get('cors.allowed_methods')[0] !== '*') {
					
					options.methods = self.app.config.get('cors.allowed_methods');
				};
				
				if (self.app.config.get('cors.allowed_headers') && self.app.config.get('cors.allowed_headers')[0] !== '*') {
					
					options.allowed_headers = self.app.config.get('cors.allowed_headers');
				};
				
				return callback(null,options);
			};
		});
	}
};
exports.default = CorsServiceResolver;