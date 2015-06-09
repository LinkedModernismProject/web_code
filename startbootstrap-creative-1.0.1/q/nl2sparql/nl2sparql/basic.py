# coding: utf-8

"""
Basic queries for nl2sparql quepy.
"""

from dsl import *
from refo import Group, Plus, Question
from quepy.parsing import Lemma, Pos, QuestionTemplate, Token, Particle, \
                          Lemmas

# Openings
LISTOPEN = Lemma("list") | Lemma("name")

class Thing(Particle):
    regex = Question(Pos("JJ")) + (Pos("NN") | Pos("NNP") | Pos("NNS")) |\
            Pos("VBN")

    def interpret(self, match):
        return HasKeyword(match.words.tokens)

class WhatIs(QuestionTemplate):
    """
    Regex for questions like "What is a blowtorch
    Ex: "What is a car"
        "What is Seinfield?"
    """

    regex = Lemma("what") + Lemma("be") + Question(Pos("DT")) + \
        Thing() + Question(Pos("."))

    def interpret(self, match):
        label = DefinitionOf(match.thing)

        return label, "define"

class RelatedTo(QuestionTemplate):
    """
    Ex. Person related to thing
        Thing related to Place
    """

    regex = Lemma("show")

class allOF(QuestionTemplate):
    """
    Ex. Show me all ____
        Are there any ____
    """
    regex = Question((Pos("PDT") | Pos("DT") | Pos("PRP$") + (Pos("NN") | Pos("NNP") | Pos("NNS")))

    def interpret(self, match):
        return self

class LivedIn(QuestionTemplate):
    """
    Ex. What ____ ____ lived in ____
        Are there any ____ from ____
        Are there any ____ that lived in ____
    """


    def interpret(self, match):






class Person(Particle):
    regex = Plus(Pos("NN") | Pos("NNS") | Pos("NNP") | Pos("NNPS"))

    def interpret(self, match):
        name = match.words.tokens
        return IsPerson() + HasKeyword(name)



class WhoMade(QuestionTemplate):
    """
    Ex. Who made Starry Night
        Who painted The Girl With The Pearl Earring
    """


class WhoIs(QuestionTemplate):
    """
    Ex: "Who is Tom Cruise?"
    """

    regex = Lemma("who") + Lemma("be") + Person() + \
        Question(Pos("."))

    def interpret(self, match):
        definition = DefinitionOf(match.person)
        return definition, "define"



class HowOldIsQuestion(QuestionTemplate):
    """
    Ex: "How old is Bob Dylan".
    """

    regex = Pos("WRB") + Lemma("old") + Lemma("be") + Person() + \
        Question(Pos("."))

    def interpret(self, match):
        birth_date = BirthDateOf(match.person)
        return birth_date, "age"


class WhereIsFromQuestion(QuestionTemplate):
    """
    Ex: "Where is Bill Gates from?"
    """

    regex = Lemmas("where be") + Person() + Lemma("from") + \
        Question(Pos("."))

    def interpret(self, match):
        birth_place = BirthPlaceOf(match.person)
        label = LabelOf(birth_place)

        return label, "enum"
