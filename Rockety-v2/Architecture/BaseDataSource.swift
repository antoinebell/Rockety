//
//  BaseDataSource.swift
//  Rockety-v2
//
//  Created by Antoine Bellanger on 06.08.20.
//  Copyright © 2020 Antoine Bellanger. All rights reserved.
//
//  Source: https://github.com/kickstarter/ios-oss/blob/master/Library/DataSource/ValueCellDataSource.swift

import Foundation
import UIKit

/**
 A type-safe wrapper around a two-dimensional array of values that can be used to provide a data source for
 `UITableView`s. There is no direct access to the two-dimensional array, and instead
 values can be appended via public methods that make sure the value you are add to the data source matches
 the type of value the table cell can handle.
 */
class BaseDataSource: NSObject, UITableViewDataSource {
    private var values: [[(value: Any, reusableId: String)]] = []
    private var cellTypes: [ValueCellType] = []
    private var registeredTypes: [UITableViewCell.Type] = []
    private var registrationNeeded = false

    /**
     Override this method to destructure `cell` and `value` in order to call the `configureWith(value:)` method
     on the cell with the value. This method is called by the internals of `ValueCellDataSource`, it does not
     need to be called directly.

     - parameter cell:  A cell that is about to be displayed.
     - parameter value: A value that is associated with the cell.
     - parameter tableView: The table view instance.
     - parameter indexPath: The current indexPath
     */
    func configureCell(tableCell cell: UITableViewCell, withValue value: Any, tableView _: UITableView, indexPath _: IndexPath) {
        if let _ = cellTypes.first(where: { $0.configure(cell, value) }) {
            // configured!
        } else {
            assertionFailure("Unrecognized (\(type(of: cell)), \(type(of: value))) combo.")
        }
    }

    /**
     Removes all values from the data source.
     */
    final func clearValues() {
        values = [[]]
        cellTypes = []
    }

    /**
     Clears all the values stored in a particular section.

     - parameter section: A section index.
     */
    final func clearValues(section: Int) {
        padValuesForSection(section)
        values[section] = []
    }

    /**
     Inserts a single value at the beginning of the section specified.

     - parameter value:     A value to prepend.
     - parameter cellClass: The type of cell associated with the value.
     - parameter section:   The section to append the value to.

     - returns: The index path of the prepended row.
     */
    @discardableResult
    final func prependRow<Cell: UITableViewCell & ValueCell,
                          Value: Any>
    (value: Value, cellClass: Cell.Type, toSection section: Int) -> IndexPath
        where
        Cell.Value == Value {
        padValuesForSection(section)
        values[section].insert((value, Cell.cellIdentifier()), at: 0)
        appendValueCellTypeIfNeeded(cellClass: cellClass)
        return IndexPath(row: 0, section: section)
    }

    @discardableResult
    final func prependRow<Cell: UITableViewCell & ValueCell & NibInstantiable,
                          Value: Any>
    (value: Value, cellClass: Cell.Type, toSection section: Int) -> IndexPath
        where
        Cell.Value == Value {
        padValuesForSection(section)
        values[section].insert((value, Cell.cellIdentifier()), at: 0)
        appendValueCellTypeIfNeeded(cellClass: cellClass)
        return IndexPath(row: 0, section: section)
    }

    /**
     Adds a single value to the end of the section specified.

     - parameter value:     A value to append.
     - parameter cellClass: The type of cell associated with the value.
     - parameter section:   The section to append the value to.

     - returns: The index path of the appended row.
     */
    @discardableResult
    final func appendRow<Cell: UITableViewCell & ValueCell,
                         Value: Any>
    (value: Value, cellClass: Cell.Type, toSection section: Int) -> IndexPath
        where
        Cell.Value == Value {
        padValuesForSection(section)
        values[section].append((value, Cell.cellIdentifier()))
        appendValueCellTypeIfNeeded(cellClass: cellClass)
        return IndexPath(row: values[section].count - 1, section: section)
    }

    @discardableResult
    final func appendRow<Cell: UITableViewCell & ValueCell & NibInstantiable,
                         Value: Any>
    (value: Value, cellClass: Cell.Type, toSection section: Int) -> IndexPath
        where
        Cell.Value == Value {
        padValuesForSection(section)
        values[section].append((value, Cell.cellIdentifier()))
        appendValueCellTypeIfNeeded(cellClass: cellClass)
        return IndexPath(row: values[section].count - 1, section: section)
    }

    /**
     Inserts a single value at the index and section specified.

     - parameter value:     A value to append.
     - parameter cellClass: The type of cell associated with the value.
     - parameter index:     The index to insert the value into
     - parameter section:   The section to insert the value into

     - returns: The index path of the inserted row.
     */

    @discardableResult
    final func insertRow<Cell: UITableViewCell & ValueCell,
                         Value: Any>
    (value: Value, cellClass: Cell.Type, atIndex index: Int, inSection section: Int) -> IndexPath
        where Cell.Value == Value {
        padValuesForSection(section)

        values[section].insert((value, Cell.cellIdentifier()), at: index)
        appendValueCellTypeIfNeeded(cellClass: cellClass)

        return IndexPath(row: index, section: section)
    }

    @discardableResult
    final func insertRow<Cell: UITableViewCell & ValueCell & NibInstantiable,
                         Value: Any>
    (value: Value, cellClass: Cell.Type, atIndex index: Int, inSection section: Int) -> IndexPath
        where Cell.Value == Value {
        padValuesForSection(section)

        values[section].insert((value, Cell.cellIdentifier()), at: index)
        appendValueCellTypeIfNeeded(cellClass: cellClass)

        return IndexPath(row: index, section: section)
    }

    final func deleteRow<Cell: UITableViewCell & ValueCell,
                         Value: Any>
    (value _: Value, cellClass _: Cell.Type, atIndex index: Int, inSection section: Int) -> IndexPath
        where Cell.Value == Value {
        padValuesForSection(section)

        values[section].remove(at: index)

        return IndexPath(row: index, section: section)
    }

    /**
     Adds a single row to the end of a section without specifying a value. This can be useful for
     providing static rows.

     - parameter cellIdentifier: The cell identifier of the static row in your table view.
     - parameter section:        The section to append the row to.
     */
    final func appendStaticRow(cellIdentifier: String, toSection section: Int) {
        padValuesForSection(section)
        values[section].append(((), cellIdentifier))
    }

    /**
     Sets an entire section of static cells.

     - parameter cellIdentifiers: A list of cell identifiers that represent the rows.
     - parameter section:         The section to replace.
     */
    final func set(cellIdentifiers: [String], inSection section: Int) {
        padValuesForSection(section)
        values[section] = cellIdentifiers.map { ((), $0) }
    }

    /**
     Appends a section of values to the end of the data source.

     - parameter values:    An array of values that make up the section.
     - parameter cellClass: The type of cell associated with all the values.
     */
    final func appendSection<Cell: UITableViewCell & ValueCell,
                             Value: Any>
    (values: [Value], cellClass: Cell.Type)
        where
        Cell.Value == Value {
        self.values.append(values.map { ($0, Cell.cellIdentifier()) })
        appendValueCellTypeIfNeeded(cellClass: cellClass)
    }

    final func appendSection<Cell: UITableViewCell & ValueCell & NibInstantiable,
                             Value: Any>
    (values: [Value], cellClass: Cell.Type)
        where
        Cell.Value == Value {
        self.values.append(values.map { ($0, Cell.cellIdentifier()) })
        appendValueCellTypeIfNeeded(cellClass: cellClass)
    }

    /**
     Replaces a section with values.

     - parameter values:    An array of values to replace the section with.
     - parameter cellClass: The type of cell associated with the values.
     - parameter section:   The section to replace.
     */
    final func set<Cell: UITableViewCell & ValueCell,
                   Value: Any>
    (values: [Value], cellClass: Cell.Type, inSection section: Int)
        where
        Cell.Value == Value {
        padValuesForSection(section)
        self.values[section] = values.map { ($0, Cell.cellIdentifier()) }
        appendValueCellTypeIfNeeded(cellClass: cellClass)
    }

    final func set<Cell: UITableViewCell & ValueCell & NibInstantiable,
                   Value: Any>
    (values: [Value], cellClass: Cell.Type, inSection section: Int)
        where
        Cell.Value == Value {
        padValuesForSection(section)
        self.values[section] = values.map { ($0, Cell.cellIdentifier()) }
        appendValueCellTypeIfNeeded(cellClass: cellClass)
    }

    /**
     Replaces a row with a value.

     - parameter value:     A value to replace the row with.
     - parameter cellClass: The type of cell associated with the value.
     - parameter section:   The section for the row.
     - parameter row:       The row to replace.
     */
    final func set<Cell: UITableViewCell & ValueCell,
                   Value: Any>
    (value: Value, cellClass: Cell.Type, inSection section: Int, row: Int)
        where
        Cell.Value == Value {
        values[section][row] = (value, Cell.cellIdentifier())
        appendValueCellTypeIfNeeded(cellClass: cellClass)
    }

    final func set<Cell: UITableViewCell & ValueCell & NibInstantiable,
                   Value: Any>
    (value: Value, cellClass: Cell.Type, inSection section: Int, row: Int)
        where
        Cell.Value == Value {
        values[section][row] = (value, Cell.cellIdentifier())
        appendValueCellTypeIfNeeded(cellClass: cellClass)
    }

    /**
     - parameter indexPath: An index path to retrieve a value.

     - returns: The value at the index path given.
     */
    final subscript(indexPath: IndexPath) -> Any {
        return values[indexPath.section][indexPath.item].value
    }

    /**
     - parameter section: The section to retrieve a value.
     - parameter item:    The item to retrieve a value.

     - returns: The value at the section, item given.
     */
    final subscript(itemSection itemSection: (item: Int, section: Int)) -> Any {
        return values[itemSection.section][itemSection.item].value
    }

    /**
     - parameter section: The section to retrieve a value.

     - returns: The array of values in the section.
     */
    final subscript(section section: Int) -> [Any] {
        return values[section].map { $0.value }
    }

    /**
     - returns: The total number of items in the data source.
     */
    final func numberOfItems() -> Int {
        return values.reduce(0) { accum, section in accum + section.count }
    }

    /**
     - returns: The total number of items in given section, in the data source.
     */
    final func numberOfItems(in section: Int) -> Int {
        return values[section].count
    }

    /**
     - parameter indexPath: An index path that we want to convert to a linear index.

     - returns: A linear index representation of the index path.
     */
    final func itemIndexAt(_ indexPath: IndexPath) -> Int {
        return values[0 ..< indexPath.section]
            .reduce(indexPath.item) { accum, section in accum + section.count }
    }

    // MARK: - UITableViewDataSource methods

    final func numberOfSections(in _: UITableView) -> Int {
        return values.count
    }

    final func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return values[section].count
    }

    final func tableView(_ tableView: UITableView,
                         cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        registerCellsIfNeeded(in: tableView)
        let (value, reusableId) = values[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: reusableId, for: indexPath)
        configureCell(tableCell: cell, withValue: value, tableView: tableView, indexPath: indexPath)
        return cell
    }

    /**
     - parameter item:    An item index.
     - parameter section: A section index.

     - returns: The reusableId associated with an (item, section) pair. Marked as internal as it's
                only useful for testing.
     */
    internal final func reusableId(item: Int, section: Int) -> String? {
        if !values.isEmpty, values.count >= section,
            !values[section].isEmpty, values[section].count >= item {
            return values[section][item].reusableId
        }
        return nil
    }

    /**
     Only useful for testing.

     - parameter itemSection: A pair containing an item index and a section index.

     - returns: The value of Any? type that is contained within the section at the item index.
     */
    internal final subscript(testItemSection itemSection: (item: Int, section: Int)) -> Any? {
        let (item, section) = itemSection

        if !values.isEmpty, values.count >= section,
            !values[section].isEmpty, values[section].count >= item {
            return values[itemSection.section][itemSection.item].value
        }
        return nil
    }

    private func padValuesForSection(_ section: Int) {
        guard values.count <= section else { return }

        (values.count ... section).forEach { _ in
            self.values.append([])
        }
    }

    private func appendValueCellTypeIfNeeded<Cell: UITableViewCell & ValueCell>(cellClass: Cell.Type) {
        if !cellTypes.contains(where: { $0.cellClass == cellClass }) {
            cellTypes.append(ValueCellType(cellClass: cellClass))
            registrationNeeded = true
        }
    }

    private func appendValueCellTypeIfNeeded<Cell: UITableViewCell & ValueCell & NibInstantiable>(cellClass: Cell.Type) {
        if !cellTypes.contains(where: { $0.cellClass == cellClass }) {
            cellTypes.append(ValueCellType(cellClass: cellClass))
            registrationNeeded = true
        }
    }

    private func registerCellsIfNeeded(in tableView: UITableView) {
        guard registrationNeeded else {
            return
        }

        // register only the cells that were not registered before
        cellTypes
            .filter { cellType in
                !registeredTypes.contains(where: { $0 == cellType.cellClass })
            }
            .forEach { cellType in
                cellType.register(tableView)
                registeredTypes.append(cellType.cellClass)
            }

        registrationNeeded = false
    }
}

// MARK: - Implementation details

// A type-erasure kind of wrapper that is initialized with the concrete cell type,
// exposing registering and configuring closures.
private struct ValueCellType {
    let cellClass: UITableViewCell.Type
    let register: (UITableView) -> Void
    let configure: (UITableViewCell, Any) -> Bool

    init<Cell: UITableViewCell & ValueCell>(cellClass: Cell.Type) {
        self.cellClass = cellClass
        register = { _ in }
        configure = Self.configureClosure(cellClass: cellClass)
    }

    init<Cell: UITableViewCell & ValueCell & NibInstantiable>(cellClass: Cell.Type) {
        self.cellClass = cellClass
        register = { tableView in
            tableView.register(cellClass.nibInstance, forCellReuseIdentifier: cellClass.cellIdentifier())
        }
        configure = Self.configureClosure(cellClass: cellClass)
    }

    private static func configureClosure<Cell: UITableViewCell & ValueCell>
    (cellClass _: Cell.Type) -> (UITableViewCell, Any) -> Bool {
        { cell, value in
            switch (cell, value) {
            case let (cell as Cell, value as Cell.Value):
                cell.configure(with: value)
                return true
            default:
                return false
            }
        }
    }
}
