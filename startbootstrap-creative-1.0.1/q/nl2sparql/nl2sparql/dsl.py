# coding: utf-8

"""
Domain specific language for nl2sparql quepy.
"""

from quepy.dsl import FixedType, HasKeyword, FixedRelation, FixedDataRelation

# Setup the Keywords for this application
HasKeyword.relation = "rdfs:label"
HasKeyword.language = "en"


class Agent(FixedType):

class GroupOrMovement(FixedType):

class Group(FixedType):

class Movement(FixedType):

class Person(FixedType):

class Actor(FixedType):

class Architect(FixedType):

class Biographer(FixedType):

class Choreographer(FixedType):

class Collector(FixedType):

class Critic(FixedType):

class Dancer(FixedType):

class Designer(FixedType):

class Director(FixedType):

class Htorian(FixedType):

class Impresario(FixedType):

class Musician(FixedType):

class Painter(FixedType):

class Patron(FixedType):

class Performer(FixedType):

class Playwright(FixedType):

class PoliticalFigure(FixedType):

class RadioPerformer(FixedType):

class RadioWriter(FixedType):

class Screenwrited(FixedType):

class Sculptor(FixedType):

class Singer(FixedType):

class TelevionPerformer(FixedType):

class TelevionWriter(FixedType):

class Thinker(FixedType):

class Typographer(FixedType):

class Writer(FixedType):

class Place(FixedType):

class Country(FixedType):

class City(FixedType):

class Empire(FixedType):

class Region(FixedType):

class Venue(FixedType):

class Production(FixedType):

class Literature(FixedType):

class Drama(FixedType):

class Poetry(FixedType):

class Prose(FixedType):

class Novel(FixedType):

class ShortStory(FixedType):

class Music(FixedType):

class Classical(FixedType):

class Experimental(FixedType):

class PopularMusic(FixedType):

class NonFiction(FixedType):

class Anthropology(FixedType):

class AutoBiography(FixedType):

class Criticm(FixedType):

class Ethnography(FixedType):

class Htory(FixedType):

class Manifesto(FixedType):

class Philosophy(FixedType):

class PoliticalTract(FixedType):

class ReligiousStudy(FixedType):

class Theory(FixedType):

class PerformingArts(FixedType):

class Dance(FixedType):

class Magic(FixedType):

class Opera(FixedType):

class RecitalReading(FixedType):

class Theatre(FixedType):

class VaidevilleMusicHall(FixedType):

class VualArts(FixedType):

class Architecture(FixedType):

class Design(FixedType):

class Drawing(FixedType):

class Film(FixedType):

class Object(FixedType):

class Painting(FixedType):

class Photography(FixedType):

class PrintMaking(FixedType):

class Sculpture(FixedType):

class Textiles(FixedType):

class Typography(FixedType):

class VualInstallation(FixedType):

class Concept(FixedType):

class ConceptOther(FixedType):

class Idea(FixedType):

class Method(FixedType):

class Style(FixedType):

class Technique(FixedType):

class Event(FixedType):

class Collection(FixedType):

class EventOther(FixedType):

class Exhibit(FixedType):

class Installation(FixedType):

class Performance(FixedType):

class PoliticalHappening(FixedType):

class Reading(FixedType):

class Revolution(FixedType):

class Riot(FixedType):

class SportingEvent(FixedType):

class War(FixedType):

class WorldFair(FixedType):


### End of Types, Start of relations


class IsAliasOf

class IsAssociatedWith

class IsAssociatedWithCity

class IsAssociatedWithCountry

class IsAssociatedWithEmpire

class IsAssociatedWithEthnicity

class IsAssociatedWithLiterature

class IsAssociatedWithRegion

class IsAssociatedWithReligion

class IsAssociatedWithVenue

class CorrespondedWith

class IsFriendOf

class HasDegree

class HasDegreeClimactic

class HasDegreeDirect

class HadDegreeKey

class HasDegreePossible

class HasDegreeProximate

class Influenced

class InfluencedDifferentKind

class InfluencedSameKind

class InfluencedBy

class InfluencedByDifferentKind

class InfluencedBySameKind

class Knows

class IsSiblingOf

class IsSpouseOf

class IsCreatedBy

class IsCreatorOf

class FoundedBy

class HasAlias

class HasMember

class HasNationality

class HasPlaceOfOrigin

class MemberOf

class MetWith

class OriginatedIn

class PerformedIn
