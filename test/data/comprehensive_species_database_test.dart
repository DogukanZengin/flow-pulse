import 'package:flutter_test/flutter_test.dart';
import '../../lib/data/comprehensive_species_database.dart';
import '../../lib/models/creature.dart';

void main() {
  group('Comprehensive Species Database Tests', () {
    test('should contain exactly 144 species', () {
      expect(ComprehensiveSpeciesDatabase.getTotalSpeciesCount(), equals(144));
    });

    test('should have 36 species in each biome', () {
      final biomeCount = ComprehensiveSpeciesDatabase.getSpeciesCountByBiome();
      
      expect(biomeCount[BiomeType.shallowWaters], equals(36));
      expect(biomeCount[BiomeType.coralGarden], equals(36));
      expect(biomeCount[BiomeType.deepOcean], equals(36));
      expect(biomeCount[BiomeType.abyssalZone], equals(36));
    });

    test('should have correct rarity distribution per biome', () {
      for (final biome in BiomeType.values) {
        final biomeSpecies = ComprehensiveSpeciesDatabase.getSpeciesForBiome(biome);
        
        final commonCount = biomeSpecies.where((s) => s.rarity == CreatureRarity.common).length;
        final uncommonCount = biomeSpecies.where((s) => s.rarity == CreatureRarity.uncommon).length;
        final rareCount = biomeSpecies.where((s) => s.rarity == CreatureRarity.rare).length;
        final legendaryCount = biomeSpecies.where((s) => s.rarity == CreatureRarity.legendary).length;
        
        expect(commonCount, equals(25), reason: 'Common species in ${biome.displayName}');
        expect(uncommonCount, equals(7), reason: 'Uncommon species in ${biome.displayName}');
        expect(rareCount, equals(3), reason: 'Rare species in ${biome.displayName}');
        expect(legendaryCount, equals(1), reason: 'Legendary species in ${biome.displayName}');
      }
    });

    test('should validate database structure', () {
      expect(ComprehensiveSpeciesDatabase.validateDatabase(), isTrue);
    });

    test('should have unique IDs for all species', () {
      final allSpecies = ComprehensiveSpeciesDatabase.allSpecies;
      final ids = allSpecies.map((s) => s.id).toSet();
      
      expect(ids.length, equals(allSpecies.length), 
        reason: 'All species should have unique IDs');
    });

    test('should have all required creature properties', () {
      final allSpecies = ComprehensiveSpeciesDatabase.allSpecies;
      
      for (final species in allSpecies) {
        expect(species.id.isNotEmpty, isTrue, reason: 'ID should not be empty');
        expect(species.name.isNotEmpty, isTrue, reason: 'Name should not be empty');
        expect(species.species.isNotEmpty, isTrue, reason: 'Scientific name should not be empty');
        expect(species.description.isNotEmpty, isTrue, reason: 'Description should not be empty');
        expect(species.pearlValue, greaterThan(0), reason: 'Pearl value should be positive');
        expect(species.discoveryChance, greaterThan(0.0), reason: 'Discovery chance should be positive');
        expect(species.discoveryChance, lessThanOrEqualTo(1.0), reason: 'Discovery chance should not exceed 1.0');
        expect(species.coralPreferences.isNotEmpty, isTrue, reason: 'Should have coral preferences');
      }
    });

    test('should have proper biome distribution', () {
      final biomeCount = ComprehensiveSpeciesDatabase.getSpeciesCountByBiome();
      
      // Each biome should have equal representation
      final expectedPerBiome = 144 ~/ 4; // 36
      for (final count in biomeCount.values) {
        expect(count, equals(expectedPerBiome));
      }
    });

    test('should have scientifically accurate naming patterns', () {
      final allSpecies = ComprehensiveSpeciesDatabase.allSpecies;
      
      for (final species in allSpecies) {
        // Scientific names should be in binomial nomenclature format
        final parts = species.species.split(' ');
        expect(parts.length, greaterThanOrEqualTo(2), 
          reason: 'Scientific name should have at least genus and species: ${species.species}');
        
        // First part (genus) should be capitalized
        expect(parts[0][0], equals(parts[0][0].toUpperCase()), 
          reason: 'Genus should be capitalized: ${species.species}');
        
        // Second part (species) should be lowercase
        expect(parts[1][0], equals(parts[1][0].toLowerCase()), 
          reason: 'Species epithet should be lowercase: ${species.species}');
      }
    });

    test('should have appropriate level requirements by biome', () {
      // Shallow waters should have lowest level requirements
      final shallowSpecies = ComprehensiveSpeciesDatabase.getSpeciesForBiome(BiomeType.shallowWaters);
      final shallowLevels = shallowSpecies.map((s) => s.requiredLevel).toList();
      final maxShallowLevel = shallowLevels.reduce((a, b) => a > b ? a : b);
      expect(maxShallowLevel, lessThanOrEqualTo(25));
      
      // Abyssal zone should have highest level requirements
      final abyssalSpecies = ComprehensiveSpeciesDatabase.getSpeciesForBiome(BiomeType.abyssalZone);
      final abyssalLevels = abyssalSpecies.map((s) => s.requiredLevel).toList();
      final minAbyssalLevel = abyssalLevels.reduce((a, b) => a < b ? a : b);
      expect(minAbyssalLevel, greaterThanOrEqualTo(51));
    });

    test('should have rarity-appropriate pearl values', () {
      final allSpecies = ComprehensiveSpeciesDatabase.allSpecies;
      
      // Group by rarity and check value ranges
      final commonSpecies = allSpecies.where((s) => s.rarity == CreatureRarity.common);
      final uncommonSpecies = allSpecies.where((s) => s.rarity == CreatureRarity.uncommon);
      final rareSpecies = allSpecies.where((s) => s.rarity == CreatureRarity.rare);
      final legendarySpecies = allSpecies.where((s) => s.rarity == CreatureRarity.legendary);
      
      // Common species should have lower values than uncommon
      final avgCommon = commonSpecies.map((s) => s.pearlValue).reduce((a, b) => a + b) / commonSpecies.length;
      final avgUncommon = uncommonSpecies.map((s) => s.pearlValue).reduce((a, b) => a + b) / uncommonSpecies.length;
      final avgRare = rareSpecies.map((s) => s.pearlValue).reduce((a, b) => a + b) / rareSpecies.length;
      final avgLegendary = legendarySpecies.map((s) => s.pearlValue).reduce((a, b) => a + b) / legendarySpecies.length;
      
      expect(avgCommon < avgUncommon, isTrue, reason: 'Common should be less valuable than uncommon');
      expect(avgUncommon < avgRare, isTrue, reason: 'Uncommon should be less valuable than rare');
      expect(avgRare < avgLegendary, isTrue, reason: 'Rare should be less valuable than legendary');
    });

    test('should have decreasing discovery chances by rarity', () {
      final allSpecies = ComprehensiveSpeciesDatabase.allSpecies;
      
      final commonSpecies = allSpecies.where((s) => s.rarity == CreatureRarity.common);
      final uncommonSpecies = allSpecies.where((s) => s.rarity == CreatureRarity.uncommon);
      final rareSpecies = allSpecies.where((s) => s.rarity == CreatureRarity.rare);
      final legendarySpecies = allSpecies.where((s) => s.rarity == CreatureRarity.legendary);
      
      final avgCommonChance = commonSpecies.map((s) => s.discoveryChance).reduce((a, b) => a + b) / commonSpecies.length;
      final avgUncommonChance = uncommonSpecies.map((s) => s.discoveryChance).reduce((a, b) => a + b) / uncommonSpecies.length;
      final avgRareChance = rareSpecies.map((s) => s.discoveryChance).reduce((a, b) => a + b) / rareSpecies.length;
      final avgLegendaryChance = legendarySpecies.map((s) => s.discoveryChance).reduce((a, b) => a + b) / legendarySpecies.length;
      
      expect(avgCommonChance > avgUncommonChance, isTrue, reason: 'Common should be more discoverable than uncommon');
      expect(avgUncommonChance > avgRareChance, isTrue, reason: 'Uncommon should be more discoverable than rare');
      expect(avgRareChance > avgLegendaryChance, isTrue, reason: 'Rare should be more discoverable than legendary');
    });

    test('should have biome-appropriate coral preferences', () {
      final allSpecies = ComprehensiveSpeciesDatabase.allSpecies;
      
      for (final species in allSpecies) {
        expect(species.coralPreferences, isNotEmpty, 
          reason: 'Species ${species.name} should have coral preferences');
        
        // Each preference should be a valid coral type
        final validCoralTypes = ['brain', 'staghorn', 'table', 'soft', 'fire'];
        for (final preference in species.coralPreferences) {
          expect(validCoralTypes.contains(preference), isTrue, 
            reason: 'Invalid coral preference: $preference for ${species.name}');
        }
      }
    });

    group('Species Filtering Tests', () {
      test('getSpeciesForBiome should return correct species', () {
        for (final biome in BiomeType.values) {
          final species = ComprehensiveSpeciesDatabase.getSpeciesForBiome(biome);
          
          expect(species.length, equals(36));
          expect(species.every((s) => s.habitat == biome), isTrue);
        }
      });

      test('getSpeciesByRarity should return correct species', () {
        final rarityCount = ComprehensiveSpeciesDatabase.getSpeciesCountByRarity();
        
        expect(rarityCount[CreatureRarity.common], equals(100)); // 25 * 4 biomes
        expect(rarityCount[CreatureRarity.uncommon], equals(28)); // 7 * 4 biomes
        expect(rarityCount[CreatureRarity.rare], equals(12)); // 3 * 4 biomes
        expect(rarityCount[CreatureRarity.legendary], equals(4)); // 1 * 4 biomes
      });
    });
  });
}