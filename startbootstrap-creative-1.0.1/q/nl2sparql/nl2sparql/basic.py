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

class 
