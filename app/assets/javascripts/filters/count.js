function CountFilter() {
  return function count(number, noun, pluralForm) {
    pluralForm || (pluralForm = noun + 's');
    noun = number === 1 ? noun : pluralForm;
    return number + ' ' + noun;
  };
}
