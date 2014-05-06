function DraftService($rootScope, $location) {
  this.$scope = $rootScope;
  this.$location = $location;
  this.$scope.draft = {};
}

DraftService.prototype.compose = function compose(email) {
  this.$scope.draft = {
    recipient_email: email
  };

  this.$location.path('/ui/compose');
};

DraftService.prototype.replyTo = function replyTo(message) {
  this.$scope.draft = {
    external_source_id: message.external_id,
    recipient_email: message.display_email,
    subject: prepend('Re: ', message.subject)
  };

  this.$location.path('/ui/compose');
};

DraftService.prototype.addCc = function addCc() {
  this.$scope.draft.include_cc = true;
};

/**
 * Prepends `prefix` to `string`, *if* not the string does not already begin
 * with that prefix.
 *
 * @param {string} prefix
 * @param {string} string
 * @returns {string}
 */
function prepend(prefix, string) {
  if (string.substring(0, prefix.length) !== prefix) {
    string = prefix + string;
  }
  return string;
}
