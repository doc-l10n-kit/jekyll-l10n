# frozen_string_literal: true

require 'asciidoctor/document'
require 'asciidoctor/table'
require_relative 'translatable_unit'
require_relative 'document_title'
require_relative 'block_title'
require_relative 'section_title'
require_relative 'table_title'
require_relative 'list_title'
require_relative 'block'
require_relative 'cell'
require_relative 'list_item'


module Jekyll
  module L10n
    module Model
      class Asciidoc
        def initialize(document)
          @document = document
        end

        def extract_units
          units = []

          walk_node(@document, units)


          units
        end

        private def walk_node(node, units)
          if node.is_a? Array
            node.each do |item|
              walk_node(item, units)
            end
            return nil
          end
          if node.is_a? Asciidoctor::Document
            node.blocks.each do |block|
              walk_node(block, units)
            end
            return nil
          end
          if node.is_a? Asciidoctor::Section
            unit = SectionTitle.new(node)
            if unit.text && !unit.text.empty?
              units.append(unit)
            end
            node.blocks.each do |block|
              walk_node(block, units)
            end
            return nil
          end
          if node.is_a? Asciidoctor::Block
            # title
            unit = BlockTitle.new(node)
            if unit.text && !unit.text.empty?
              units.append(unit)
            end

            # body
            unit = Block.new(node)
            if unit.text && !unit.text.empty? && unit.node.style != 'source'
              units.append(unit)
            end
            node.blocks.each do |block|
              walk_node(block, units)
            end
            return nil
          end
          if node.is_a? Asciidoctor::Table
            unit = TableTitle.new(node)
            if unit.text && !unit.text.empty?
              units.append(unit)
            end
            node.rows.head.each do |cell|
              walk_node(cell, units)
            end
            node.rows.body.each do |cell|
              walk_node(cell, units)
            end
            node.rows.foot.each do |cell|
              walk_node(cell, units)
            end
            return nil
          end
          if node.is_a? Asciidoctor::Table::Cell
            unit = Cell.new(node)
            if unit.text && !unit.text.empty?
              units.append(unit)
            end
            node.blocks.each do |block|
              walk_node(block, units)
            end
            return nil
          end
          if node.is_a? Asciidoctor::List
            unit = ListTitle.new(node)
            if unit.text && !unit.text.empty?
              units.append(unit)
            end
            node.blocks.each do |block|
              walk_node(block, units)
            end
            return nil
          end
          if node.is_a? Asciidoctor::ListItem
            unit = ListItem.new(node)
            if unit.text && !unit.text.empty?
              units.append(unit)
            end
            node.blocks.each do |block|
              walk_node(block, units)
            end
            return nil
          end

          node
        end


      end
    end
  end
end

