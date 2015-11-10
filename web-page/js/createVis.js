function constructPred(term) {
  return 'SELECT distinct * WHERE { ?Subject ?Predicate ?Object . ?Subject limo:' + term + ' ?Object .} ORDER BY ASC(?Subject)';
}

function createVis(term, qry) {
  console.log('in createVis~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~');
  var preds = {
    'Is your term an ': null,
    'Music': null,
    'NonFictionOrConceptOrIdeaTypeOfWriting': null,
    'PerformingArts': null,
    'VisualArts': null,
    'artifactNature': null,
    'associatedMovement': null,
    'associatedWith': null,
    'associatedWithBuddhism': null,
    'associatedWithChristianity': null,
    'associatedWithCities': null,
    'associatedWithCountry': null,
    'associatedWithEmpire': null,
    'associatedWithEthnicity': null,
    'associatedWithHinduism': null,
    'associatedWithIslam': null,
    'associatedWithJudaism': null,
    'associatedWithLiterature': null,
    'associatedWithMovementOrConcept': null,
    'associatedWithOtherReligion': null,
    'associatedWithRegion': null,
    'associatedWithReligion': null,
    'associatedWithSikhis': null,
    'associatedWithTechnique': null,
    'associatedWithVenues': null,
    'correspondedWith': null,
    'createdBy': null,
    'createdByIndirect': null,
    'creatorOf': null,
    'flourishesIn': null,
    'founderOrLeader': null,
    'groupOrMovement': null,
    'groupOrMovementInternationalOrParochial': null,
    'hasAlias': null,
    'hasBirthdate': null,
    'hasDeathdate': null,
    'hasGender': null,
    'hasSex': null,
    'hasSexuality': null,
    'includesParatext': null,
    'influenced': null,
    'influencedBy': null,
    'influencedByDifferentKind': null,
    'influencedDifferentKind': null,
    'initiallyAppearedInVenue': null,
    'isArtifact': null,
    'isArtifactForgedPiratedFakedMisappropriatedAndCirculatedSpuriouisly': null,
    'isEvent': null,
    'isPerson': null,
    'isTranslated': null,
    'knows': null,
    'membersOrFiguresAssociatedWithGroupOrMovement': null,
    'natureOfEvent': null,
    'originatingCountry': null,
    'seeAlso': null,
    'timeOfForgerySinceInitialAppearance': null,
    'timeToTranslation': null,
    'translationTargetLanguage': null,
    'typeOfEvent': null,
    'typeOfPerson': null,
    'usesLanguage': null,
    'usesPrimaryLanguage': null,
    'worksAlludedOrReferredTo': null,
    'worksOrEventsMostCommonlyAssociatedWithGroupOrMovement': null,
  }
  console.log('in the createVis~~~~~~~~~~~~~~~~~~~~~~~~~~'+ qry);
  console.log(term);
  if (term in preds) {
    console.log('YES ITS IN THE PREDSŚSŠŚ');
    query = constructPred(term);
  } else if (term.replace('_', '') in preds) {
    term_r = term.replace('_', '');
    query = constructPred(term_r);
  } else {
    query = qry;
  }
  var endpoint = /*"http://dbpedia.org/sparql";*/ "http://linkedmods.uvic.ca:8890/sparql?default-graph-uri=http://localhost:8890/bestDataProduction&";
  console.log(endpoint);
  console.log(render);
  var tes = d3sparql.query(endpoint, query, render);
  console.log(tes);
}
