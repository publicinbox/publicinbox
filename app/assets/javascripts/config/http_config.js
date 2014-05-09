function HttpConfig($httpProvider) {
  function HttpInterceptor($rootScope, $q) {
    var outstandingRequests = 0;

    var interceptor = {
      request: function(config) {
        interceptor.updateState(++outstandingRequests);
        return config;
      },

      requestError: function(error) {
        interceptor.updateState(--outstandingRequests);
        return $q.reject(error);
      },

      response: function(response) {
        interceptor.updateState(--outstandingRequests);
        return response;
      },

      responseError: function(error) {
        interceptor.updateState(--outstandingRequests);
        return $q.reject(error);
      },

      updateState: function(requestCount) {
        $rootScope.app.state = requestCount > 0 ? 'loading' : 'ready';
      }
    };

    return interceptor;
  }

  HttpInterceptor.$inject = ['$rootScope', '$q'];

  $httpProvider.interceptors.push(HttpInterceptor);
}

HttpConfig.$inject = ['$httpProvider'];
