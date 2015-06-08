# coding: utf-8

"""
Domain specific language for nl2sparql quepy.
"""

from quepy.dsl import FixedType, HasKeyword, FixedRelation, FixedDataRelation

# Setup the Keywords for this application
HasKeyword.relation = "rdfs:label"
HasKeyword.language = "en"


class Agent(FixedType):
    fixedtype = "linkedmods:Agent"

class GroupOrMovement(FixedType):
    fixedtype = "linkedmods:GroupOrMovement"

class Group(FixedType):
    fixedtype = "linkedmods:Group"

class Movement(FixedType):
    fixedtype = "linkedmods:Movement"

class Person(FixedType):
    fixedtype = "linkedmods:Person"

class Actor(FixedType):
    fixedtype = "linkedmods:Actor"

class Architect(FixedType):
    fixedtype = "linkedmods:Architect"

class Biographer(FixedType):
    fixedtype = "linkedmods:Biographer"

class Choreographer(FixedType):
    fixedtype = "linkedmods:Choreographer"

class Collector(FixedType):
    fixedtype = "linkedmods:Collector"

class Critic(FixedType):
    fixedtype = "linkedmods:Critic"

class Dancer(FixedType):
    fixedtype = "linkedmods:Dancer"

class Designer(FixedType):
    fixedtype = "linkedmods:Designer"

class Director(FixedType):
    fixedtype = "linkedmods:Director"

class Historian(FixedType):
    fixedtype = "linkedmods:Historian"

class Impresario(FixedType):
    fixedtype = "linkedmods:Impresario"

class Musician(FixedType):
    fixedtype = "linkedmods:Musician"

class Painter(FixedType):
    fixedtype = "linkedmods:Painter"

class Patron(FixedType):
    fixedtype = "linkedmods:Patron"

class Performer(FixedType):
    fixedtype = "linkedmods:Performer"

class Playwright(FixedType):
    fixedtype = "linkedmods:Playwright"

class PoliticalFigure(FixedType):
    fixedtype = "linkedmods:PoliticalFigure"

class RadioPerformer(FixedType):
    fixedtype = "linkedmods:RadioPerformer"

class RadioWriter(FixedType):
    fixedtype = "linkedmods:RadioWriter"

class Screenwriter(FixedType):
    fixedtype = "linkedmods:Screenwriter"

class Sculptor(FixedType):
    fixedtype = "linkedmods:Sculptor"

class Singer(FixedType):
    fixedtype = "linkedmods:Singer"

class TelevionPerformer(FixedType):
    fixedtype = "linkedmods:TelevionPerformer"

class TelevionWriter(FixedType):
    fixedtype = "linkedmods:TelevionWriter"

class Thinker(FixedType):
    fixedtype = "linkedmods:Thinker"

class Typographer(FixedType):
    fixedtype = "linkedmods:Typographer"

class Writer(FixedType):
    fixedtype = "linkedmods:Writer"

class Place(FixedType):
    fixedtype = "linkedmods:Place"

class Country(FixedType):
    fixedtype = "linkedmods:Country"

class City(FixedType):
    fixedtype = "linkedmods:City"

class Empire(FixedType):
    fixedtype = "linkedmods:Empire"

class Region(FixedType):
    fixedtype = "linkedmods:Region"

class Venue(FixedType):
    fixedtype = "linkedmods:Venue"

class Production(FixedType):
    fixedtype = "linkedmods:Production"

class Literature(FixedType):
    fixedtype = "linkedmods:Literature"

class Drama(FixedType):
    fixedtype = "linkedmods:Drama"

class Poetry(FixedType):
    fixedtype = "linkedmods:Poetry"

class Prose(FixedType):
    fixedtype = "linkedmods:Prose"

class Novel(FixedType):
    fixedtype = "linkedmods:Novel"

class ShortStory(FixedType):
    fixedtype = "linkedmods:ShortStory"

class Music(FixedType):
    fixedtype = "linkedmods:Music"

class Classical(FixedType):
    fixedtype = "linkedmods:Classical"

class Experimental(FixedType):
    fixedtype = "linkedmods:Experimental"

class PopularMusic(FixedType):
    fixedtype = "linkedmods:PopularMusic"

class NonFiction(FixedType):
    fixedtype = "linkedmods:NonFiction"

class Anthropology(FixedType):
    fixedtype = "linkedmods:Anthropology"

class AutoBiography(FixedType):
    fixedtype = "linkedmods:AutoBiography"

class Criticm(FixedType):
    fixedtype = "linkedmods:Criticm"

class Ethnography(FixedType):
    fixedtype = "linkedmods:Ethnography"

class History(FixedType):
    fixedtype = "linkedmods:History"

class Manifesto(FixedType):
    fixedtype = "linkedmods:Manifesto"

class Philosophy(FixedType):
    fixedtype = "linkedmods:Philosophy"

class PoliticalTract(FixedType):
    fixedtype = "linkedmods:PoliticalTract"

class ReligiousStudy(FixedType):
    fixedtype = "linkedmods:ReligiousStudy"

class Theory(FixedType):
    fixedtype = "linkedmods:Theory"

class PerformingArts(FixedType):
    fixedtype = "linkedmods:PerformingArts"

class Dance(FixedType):
    fixedtype = "linkedmods:Dance"

class Magic(FixedType):
    fixedtype = "linkedmods:Magic"

class Opera(FixedType):
    fixedtype = "linkedmods:Opera"

class RecitalReading(FixedType):
    fixedtype = "linkedmods:RecitalReading"

class Theatre(FixedType):
    fixedtype = "linkedmods:Theatre"

class VaudevilleMusicHall(FixedType):
    fixedtype = "linkedmods:VaudevilleMusicHall"

class VisualArts(FixedType):
    fixedtype = "linkedmods:VisualArts"

class Architecture(FixedType):
    fixedtype = "linkedmods:Architecture"

class Design(FixedType):
    fixedtype = "linkedmods:Design"

class Drawing(FixedType):
    fixedtype = "linkedmods:Drawing"

class Film(FixedType):
    fixedtype = "linkedmods:Film"

class Object(FixedType):
    fixedtype = "linkedmods:Object"

class Painting(FixedType):
    fixedtype = "linkedmods:Painting"

class Photography(FixedType):
    fixedtype = "linkedmods:Photography"

class PrintMaking(FixedType):
    fixedtype = "linkedmods:PrintMaking"

class Sculpture(FixedType):
    fixedtype = "linkedmods:Sculpture"

class Textiles(FixedType):
    fixedtype = "linkedmods:Textiles"

class Typography(FixedType):
    fixedtype = "linkedmods:Typography"

class VisualInstallation(FixedType):
    fixedtype = "linkedmods:VisualInstallation"

class Concept(FixedType):
    fixedtype = "linkedmods:Concept"

class ConceptOther(FixedType):
    fixedtype = "linkedmods:ConceptOther"

class Idea(FixedType):
    fixedtype = "linkedmods:Idea"

class Method(FixedType):
    fixedtype = "linkedmods:Method"

class Style(FixedType):
    fixedtype = "linkedmods:Style"

class Technique(FixedType):
    fixedtype = "linkedmods:Technique"

class Event(FixedType):
    fixedtype = "linkedmods:Event"

class Collection(FixedType):
    fixedtype = "linkedmods:Collection"

class EventOther(FixedType):
    fixedtype = "linkedmods:EventOther"

class Exhibit(FixedType):
    fixedtype = "linkedmods:Exhibit"

class Installation(FixedType):
    fixedtype = "linkedmods:Installation"

class Performance(FixedType):
    fixedtype = "linkedmods:Performance"

class PoliticalHappening(FixedType):
    fixedtype = "linkedmods:PoliticalHappening"

class Reading(FixedType):
    fixedtype = "linkedmods:Reading"

class Revolution(FixedType):
    fixedtype = "linkedmods:Revolution"

class Riot(FixedType):
    fixedtype = "linkedmods:Riot"

class SportingEvent(FixedType):
    fixedtype = "linkedmods:SportingEvent"

class War(FixedType):
    fixedtype = "linkedmods:War"

class WorldFair(FixedType):
    fixedtype = "linkedmods:WorldFair"


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
    foaf Knows

class made
    foaf made

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
